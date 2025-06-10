// SPDX-License-Identifier: MIT
pragma solidity > 0.8.0;


contract Auction{

/* Type declarations */

    struct Bidder{
        address addressBider;
        uint256 amountRefund;
        uint256 amountBid;
        uint256 offerTime;
    }

    Bidder[] private bidders;
    
    struct Winner{
        address addressWinner;
        uint256 amountBid;
        uint256 offerTime;
    }
        
    Winner public winner;


/* State variables*/

   
    uint256 constant MIN_WEI = 100;
    address ownerContract;
    uint256 auctionStart;
    uint256 auctionEnd;
    uint256 extAuctionOffer;
    uint256 actualTime;
    uint256 incrementPercent;
    uint256 bidPrice;
    uint256 amountBid;
    uint256 gasCharge;
   


/* Events */

    event NewOffer(address indexed Bidder, uint256 amount);
    event AuctionEnded( uint256 endTime);
    event AuctionWinner(address indexed  winner, uint256 value);
 

/* Mofifiers */ 

    modifier onlyOwnerContract(){
    require(ownerContract== msg.sender, "You do not have permission to perform the operation");
    _;
    }

    modifier onlyIsActive(){
    require(block.timestamp < auctionEnd,"Auction ended");
    _;
    }
    
    modifier onlyValidTime(){
    require( block.timestamp <  auctionEnd , "No offers can be made");
    _;
}
    modifier onlyValidOffer(){
        require( msg.value >= MIN_WEI, "Must be at least 100");
        _;
    }


/* Constructor */

    constructor( uint256 bidPrice_, uint256 incrementPercent_, uint256 auctionEnd_, uint256 gasCharge_,
                 uint256 extAuctionOffer_) {
        ownerContract = msg.sender;
        bidPrice = bidPrice_;
        incrementPercent = incrementPercent_;
        gasCharge = gasCharge_;
        auctionStart = block.timestamp;
        auctionEnd = block.timestamp + auctionEnd_ * 1 days;
        extAuctionOffer = extAuctionOffer_;
    }


/* Getters */

    function getBidPrice() public view returns (uint256) {
        return bidPrice;
    }
    function geIncrementPercent() public view returns (uint256) {
        return  incrementPercent;
    }

    function getMinBid() public view returns (uint256) {
        return bidPrice * (100 + incrementPercent) / 100;
    }

    function getGasCharge() public view returns (uint256) {
        return gasCharge;
    }

/* Setters */

    function setAuctionEnd ( uint256 endTime_) external  onlyOwnerContract onlyIsActive {
        assert(endTime_ > auctionStart);
        auctionEnd = endTime_;
    }   

    function setAuctionStart ( uint256 value_) external onlyOwnerContract onlyIsActive {
        auctionStart = block.timestamp;
        assert( value_ > auctionStart);
        auctionStart = value_;
    }

    function setOfferPercent(uint256 percent_)  external onlyOwnerContract {
        incrementPercent = 100 + percent_;
    }

    function finishAuction() external onlyOwnerContract onlyIsActive {
        auctionEnd = block.timestamp;
        emit AuctionEnded (auctionEnd);
    }

    function setGasCharge(uint256 percent_) external onlyOwnerContract {
       gasCharge = percent_;
    }

    function setAuctionOffer(uint256 time_) external onlyOwnerContract {
        extAuctionOffer = time_  * 1 minutes ;
    }

/* Gas's functions */

    function addGasCharge( uint total) internal returns (uint256){
        return  gasCharge  = total - (total * gasCharge) / 100;
    }


/* Time's functions */

    function extendTimeBid() internal {
        if ((auctionEnd - auctionStart) < extAuctionOffer ) {
            auctionEnd += extAuctionOffer;
        }
    }


/* Bidder's function */

    function searchBidder(address bidder) internal view returns (bool exists, uint256 index) {
        for (uint256 i = 0; i < bidders.length; i++) {
            if (bidders[i].addressBider == bidder) {
                return (true, i); 
            }
    }
        return (false, 0); 
    }

    function addBidder() internal {
            bidders.push(Bidder({
            addressBider: msg.sender,
            amountRefund: 0,
            amountBid: msg.value,
            offerTime: block.timestamp
        }));
    }


/* Bid's functions */

    function placeBid()  external payable onlyIsActive  onlyValidTime onlyValidOffer {
        uint256 index;
        bool exists;
        uint256 minBid = bidPrice * (100 + incrementPercent) / 100;
        require(msg.value > minBid, "Insufficient bid amount");
        (exists , index) = searchBidder(msg.sender); 

        if (exists){
            bidders[index].offerTime = block.timestamp;
            bidders[index].amountRefund += bidders[index].amountBid;
            bidders[index].amountBid = msg.value ;
        } else {
           addBidder();
        }
        
        emit NewOffer(msg.sender, msg.value );
        updateWinner();
        bidPrice = msg.value;
        extendTimeBid();
    }



/* Refund's functions */

    function refund(uint256 amount) internal{
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Refund failed");
    }
        
    function partialRefund(uint256 amount) external payable  onlyValidTime {
        require(amount > 0, "Refund amount must be positive");

        (, uint256 i) = searchBidder(msg.sender);
       
        require(bidders[i].amountRefund >= amount, "Refund exceeds available amount");

        refund(amount);
        bidders[i].amountRefund -= amount;
    }

    function returnAllRefunds() external payable onlyOwnerContract {
        uint256 amountRefund;
        uint256 total;

        require( block.timestamp > auctionEnd, "Not enough time to return alll refunds");
      
        for (uint256 i = 0; i < bidders.length; i++){
            total = bidders[i].amountRefund += amountBid;
            amountRefund = addGasCharge(total);
            (bool success, ) = msg.sender.call{value: amountRefund}("");
            require(success, "Refund error");
        }
    }


/* Bidder's functions */

    function showAllBidders() external  view returns(Bidder[] memory){
        return bidders;
    }


/* Winner's functions*/

    function updateWinner() internal{
        winner.addressWinner = msg.sender;
        winner.amountBid = msg.value ;
        winner.offerTime = block.timestamp;
    }

    function showWinner() external  view returns (Winner memory ){
        return winner;
    }
}
