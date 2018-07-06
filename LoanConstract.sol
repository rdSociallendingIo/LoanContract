pragma solidity ^0.4.0;

contract LoanContract {
    ///
    struct LoanEntity {
        string loanId;
        uint32 publishTime;
        uint32 repayTime;
        LoanStatus loanStatus;
        string borrower;
        string lender;
        string amount;
        string interest;
        uint32 lendEffectTime;
        uint32 actualRepayTime;
        string lendMd5;
        string repayMd5;
        IsAppeal isAppeal;
    }

    enum LoanStatus {
        publish,
        locked,
        releaseToConfirm,
        releaseConfirmed,
        repayToConfirm,
        repayConfirmed
    }

    enum IsAppeal {
        no,
        yes,
        finish
    }

    mapping(string => LoanEntity) loanDataMap;

    // 已放款待确认
    event ReleaseToConfirm(string loanId);

    //已放款待确认 -> 已放款
    event ReleaseBeConfirmed(string loanId);

    // 已放款待确认时申诉
    event AppealInReleaseToConfirm(string loanId);

    // 已放款待确认时取消申诉（转为发布中或者为已放款）
    event CancelAppealInReleaseToConfirm(string loanId);

    //已放款 -> 已还款待确认
    event RepayToConfirm(string loanId);

    //已还款待确认->已还款
    event RepayBeConfirmed(string loanId);

    //已还款待确认时申诉
    event AppealInRepayToConfirm(string loanId);

    //还款待确认时取消申诉（转为已放款或者为已还款）
    event CancelAppealInRepayToConfirm(string loanId);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address public owner;

    function LoanContract(address _owner) public {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier checkExist(string loanId) {
        bytes memory _byte1 = bytes(loanId);
        bytes memory _byte2 = bytes(loanDataMap[loanId].loanId);
        require(_byte1.length>0 && _byte2.length>0);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != owner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // 已放款待确认
    function releaseLoan(string loanId, uint32 publishTime, uint32 repayTime, string borrower,
        string lender, string amount, string interest) public onlyOwner()  {
        loanDataMap[loanId].loanId = loanId;
        loanDataMap[loanId].publishTime = publishTime;
        loanDataMap[loanId].repayTime = repayTime;
        loanDataMap[loanId].loanStatus = LoanStatus.releaseToConfirm;
        loanDataMap[loanId].borrower = borrower;
        loanDataMap[loanId].lender = lender;
        loanDataMap[loanId].amount = amount;
        loanDataMap[loanId].interest = interest;
        loanDataMap[loanId].isAppeal = IsAppeal.no;
        loanDataMap[loanId].lendEffectTime = publishTime;
        ReleaseToConfirm(loanId);
    }

    //已放款待确认 -> 已放款
    function confirmReleaseLoan(string loanId, string lendMd5) public onlyOwner() checkExist(loanId) {
        loanDataMap[loanId].loanStatus = LoanStatus.releaseConfirmed;
        loanDataMap[loanId].lendMd5 = lendMd5;
        ReleaseBeConfirmed(loanId);
    }

    // 已放款待确认时申诉
    function appeal(string loanId) public onlyOwner() checkExist(loanId) {
        loanDataMap[loanId].isAppeal = IsAppeal.yes;
        AppealInReleaseToConfirm(loanId);
    }

    // 已放款待确认时取消申诉（转为发布中或者为已放款）
    function cancelAppeal(string loanId) public onlyOwner() checkExist(loanId) {
        loanDataMap[loanId].isAppeal = IsAppeal.finish;
        CancelAppealInReleaseToConfirm(loanId);
    }

    //已放款 -> 已还款待确认
    function repayToConfirm(string loanId, uint32 actualRepayTime) public onlyOwner() checkExist(loanId) {
        loanDataMap[loanId].loanStatus = LoanStatus.repayToConfirm;
        loanDataMap[loanId].actualRepayTime = actualRepayTime;
        RepayToConfirm(loanId);
    }

    //已还款待确认->已还款
    function repayBeConfirmed(string loanId, string repayMd5) public onlyOwner() checkExist(loanId) {
        loanDataMap[loanId].loanStatus = LoanStatus.repayConfirmed;
        loanDataMap[loanId].repayMd5 = repayMd5;
        RepayBeConfirmed(loanId);
    }

    function getFirstLoanDataById(string id) public view
        returns (uint32, uint32, LoanStatus, string, string, string) {
        return (
            loanDataMap[id].publishTime,
            loanDataMap[id].repayTime,
            loanDataMap[id].loanStatus,
            loanDataMap[id].borrower,
            loanDataMap[id].lender,
            loanDataMap[id].amount);
    }

    function getSecondLoanDataById(string id) public view
        returns (string, uint32, uint32, string, string, IsAppeal) {
        return (
            loanDataMap[id].interest,
            loanDataMap[id].lendEffectTime,
            loanDataMap[id].actualRepayTime,
            loanDataMap[id].lendMd5,
            loanDataMap[id].repayMd5,
            loanDataMap[id].isAppeal);
    }

}

