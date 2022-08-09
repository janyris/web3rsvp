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
            abi.encodePacked (
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

    require(idToEvent[eventID].eventTimestamp == 0, "ALREADY REGISTERED");

    
        );
    

    }


}