// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.7;

// import "contracts/temp/VRFCoordinatorV2Interface.sol"; //temporary
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
// import "contracts/temp/VRFConsumerBaseV2.sol";         //temporary
import "./VRFConsumerBaseV2.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract VRFv2Consumer is VRFConsumerBaseV2 {
  VRFCoordinatorV2Interface COORDINATOR;

  // Your subscription ID.
  uint64 s_subscriptionId;

  // Goerli coordinator. For other networks,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  // address vrfCoordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;

  // The gas lane to use, which specifies the maximum gas price to bump to.
  // For a list of available gas lanes on each network,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  // bytes32 keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;

  // Depends on the number of requested values that you want sent to the
  // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
  // so 100,000 is a safe default for this example contract. Test and adjust
  // this limit based on the network that you select, the size of the request,
  // and the processing of the callback request in the fulfillRandomWords()
  // function.
  uint32 callbackGasLimit;

  address vrfCoordinator;

  bytes32 keyHash;

  // The default is 3, but you can set this higher.
  uint16 requestConfirmations;

  // For this example, retrieve 2 random values in one request.
  // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
  uint32 numWords;

  uint256[] internal s_randomWords;
  uint256 public s_requestId;
  address s_owner;

  

function initializeV2Consumer(uint64 subscriptionId ) internal {
  callbackGasLimit = 100000;
  requestConfirmations = 3;
  numWords =  1;
  vrfCoordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;
  keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
  COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
  setCoordinator(vrfCoordinator);
  s_owner = msg.sender;
  s_subscriptionId = subscriptionId;
}
  // Assumes the subscription is funded sufficiently.
  function requestRandomWords() internal returns(uint256){
    // Will revert if subscription is not set and funded.
    s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
    return s_requestId;
  }

  function fulfillRandomWords(
    uint256  /* requestId */,
    uint256[] memory randomWords
  ) internal virtual override {
    s_randomWords = randomWords;
  }


}