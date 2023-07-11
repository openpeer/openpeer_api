async function resolve_dispute(address, orderId, buyer, token, amount) {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  await provider.send('eth_requestAccounts', []);
  const signer = provider.getSigner();

  const select = document.getElementById('winner_id');
  const winnerAddress = select.value;
  const abi = [
    {
      inputs: [
        {
          internalType: 'bytes32',
          name: '_orderID',
          type: 'bytes32'
        },
        {
          internalType: 'address payable',
          name: '_buyer',
          type: 'address'
        },
        {
          internalType: 'address',
          name: '_token',
          type: 'address'
        },
        {
          internalType: 'uint256',
          name: '_amount',
          type: 'uint256'
        },
        {
          internalType: 'address payable',
          name: '_winner',
          type: 'address'
        }
      ],
      name: 'resolveDispute',
      outputs: [
        {
          internalType: 'bool',
          name: '',
          type: 'bool'
        }
      ],
      stateMutability: 'nonpayable',
      type: 'function'
    }
  ];

  const contract = new ethers.Contract(address, abi, signer);

  try {
    console.log({ address, orderId, buyer, token, amount });
    await contract.resolveDispute(orderId, buyer, token, amount, winnerAddress);
  } catch (error) {
    alert(error);
  }
}
