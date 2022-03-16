// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Thrift
 * @dev Add, View & Recovery Thrift
 */
contract Thrift {
	struct OneThrift {
		uint dateAdded;
		uint amountAdded;
	}
	address private owner;
	uint private today;
	uint availableThrift;
	uint noAvailableThrift;
	// mapping(uint => uint) public oneThrift;
	OneThrift[] private thriftHistory;

	// event for EVM logging
	event OwnerSet(address indexed originalOwner);

	// modifier to check if caller is owner
	modifier isOwner() {
		require(msg.sender == owner, "Caller is not owner");
		_;
	}

	/**
	 * @dev Set contract deployer as owner
	 */
	constructor() {
		owner = msg.sender; 
		emit OwnerSet(owner);
	}

	/**
	 * @dev Set Thrift
	 */
	function setThrift() public payable isOwner{
		require(msg.value > 0, "You need to save more ! ;)");
		today = block.timestamp;
		OneThrift memory oneThrift = OneThrift(today, msg.value);
		thriftHistory.push(oneThrift);
	}

	/**
	 * @dev Recovery
	 * @param _amount amount to withdraw from savings
	 */
	function recoveryThrift(uint _amount) public isOwner {
		require(_amount > 0, "Realy ? ;)");
		uint tempAvailableThrift = availableThrift;
		today = block.timestamp;
		for (uint i = 0; i < thriftHistory.length; i++) {
			if(thriftHistory[i].dateAdded  + 12 weeks > today) {
				tempAvailableThrift += thriftHistory[i].amountAdded;
			}
		}
		require(tempAvailableThrift == 0 , "no thrift available");
		require(tempAvailableThrift < _amount, "insufficient available thrift");
		(bool sent, ) = payable(msg.sender).call{value: _amount}("");
		require(sent, "error in withdrawal");
		while(_amount != 0) {
			for (uint i = 0; i < thriftHistory.length; i++) {
				if(thriftHistory[i].dateAdded  + 12 weeks > today ){
					if(thriftHistory[i].amountAdded <= _amount) {
						_amount -= thriftHistory[i].amountAdded;
						delete thriftHistory[i];
					}else{
						thriftHistory[i].amountAdded -= _amount;
						_amount = 0;
					}
				}
			}
		}
	} 

	/**
	 * @dev View thrift
	 * @return thriftFull no & available thrift
	 */
	function getThrift() external isOwner returns (string memory thriftFull){
		today = block.timestamp;
		uint tempAvailableThrift = availableThrift;
		uint tempNoAvailableThrift = noAvailableThrift;
		for (uint i = 0; i < thriftHistory.length; i++) {
			if(thriftHistory[i].dateAdded  + 12 weeks > today) {
				tempAvailableThrift += thriftHistory[i].amountAdded;
			}else{
				tempNoAvailableThrift += thriftHistory[i].amountAdded;
			}
		}
		return string(abi.encodePacked('available thrift : ',uint2str(tempAvailableThrift),', no available thrift : ',uint2str(tempNoAvailableThrift)));
	}

	function uint2str(uint256 _i) internal pure returns (string memory str) {
		if (_i == 0) {
			return "0";
		}
		uint256 j = _i;
		uint256 length;
		while (j != 0) {
			length++;
			j /= 10;
		}
		bytes memory bstr = new bytes(length);
		uint256 k = length;
		j = _i;
		while (j != 0) {
			bstr[--k] = bytes1(uint8(48 + j % 10));
			j /= 10;
		}
		str = string(bstr);
	}
}