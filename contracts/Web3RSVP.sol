// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


contract Web3RSVP {
    struct CreateEvent {
        bytes32 eventId;
        string eventDataCID;
        address eventOwer;
        uint256 evenTimestamp;
        uint256 deposit;
        uint256 maxCapacity;
        address[] confirmedRSVPs;
        address[] claimedRSVPs;
        bool paidOut;
    }

    mapping(bytes32 => CreateEvent) public idToEvent;
    
    function createNewEvent(
        uint256 eventTimestamp,
        uint256 deposit,
        uint256 maxCapacity,
        string calldata eventDataCID
    ) external {

    bytes32 eventId = keccak256(
            abi.encodePacked(
                msg.sender,
                address(this),
                eventTimestamp,
                deposit,
                maxCapacity,
            )
        );

        addresss[] memory confrimedRSVPs;
        addresss[] memory claimedRSVPs;

        idToEvent[eventId] = CreateEvent(
            eventId,
            eventDataCID,
            msg.sender,
            eventTimestamp,
            deposit,
            maxCapacity,
            confrimedRSVPs,
            claimedRSVPs,
            false

    require (idToEvent[eventID].eventTimestamp == 0, "ALREADY REGISTERED");


        );
    

    }


}


function createNewRSVP(bytes32 eventId) external payable {

    CreateEvent storage myEvent = idToEvent[eventId];

    require(msg.value == myEvent.deposit, "NOT ENOUGH");

    require(block.timestamp <= myEvent.eventTimestamp, "ALREADY HAPPENED");

    require(
        myEvent.confirmedRSVPs.length < myEvent.maxCapacity,
        "This event has reached capacity"
    );

    for (uint8 i = 0; i < myEvent.confirmedRSVPs.length; i++) {
        require(myEvent.confirmedRSVPs[i] != msg.sender, "ALREADY CONFIRMED");
    }

    myEvent.confirmedRSVPs.push(payable(msg.sender));

}

function confirmAttendee(bytes32 eventId, address attendee) public {

    CreateEvent storage myEvent = idToEvent[eventId];

    require(msg.sender == myEvent.eventOwner, "NOT AUTHORIZED");

    address rsvpConfirm;

    for (uint8 i = 0; i < myEvent.confirmedRSVPs.length; i++) {
        if(myEvent.confirmedRSVPs[i] == attendee){
            rsvpConfirm = myEvent.confirmedRSVPs[i];
        }
    }

    require(rsvpConfirm == attendee, "NO RSVP TO CONFIRM");


    for (uint8 i = 0; i < myEvent.claimedRSVPs.length; i++) {
        require(myEvent.claimedRSVPs[i] != attendee, "ALREADY CLAIMED");
    }

    require(myEvent.paidOut == false, "ALREADY PAID OUT");

    myEvent.claimedRSVPs.push(attendee);

    (bool sent,) = attendee.call{value: myEvent.deposit}("");

    if (!sent) {
        myEvent.claimedRSVPs.pop();
    }

    require(sent, "Failed to send Ether");
}

function confirmAllAttendees(bytes32 eventId) external {

    CreateEvent memory myEvent = idToEvent[eventId];

    require(msg.sender == myEvent.eventOwner, "NOT AUTHORIZED");

    for (uint8 i = 0; i < myEvent.confirmedRSVPs.length; i++) {
        confirmAttendee(eventId, myEvent.confirmedRSVPs[i]);
    }
}

function withdrawUnclaimedDeposits(bytes32 eventId) external {

    CreateEvent memory myEvent = idToEvent[eventId];

    require(!myEvent.paidOut, "ALREADY PAID");

    require(
        block.timestamp >= (myEvent.eventTimestamp + 7 days),
        "TOO EARLY"
    );

    require(msg.sender == myEvent.eventOwner, "MUST BE EVENT OWNER");

    uint256 unclaimed = myEvent.confirmedRSVPs.length - myEvent.claimedRSVPs.length;

    uint256 payout = unclaimed * myEvent.deposit;

    myEvent.paidOut = true;

    (bool sent, ) = msg.sender.call{value: payout}("");

    if (!sent) {
        myEvent.paidOut = false;
    }

    require(sent, "Failed to send Ether");

}