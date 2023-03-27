async function resolve_dispute(address) {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  await provider.send('eth_requestAccounts', []);
  const signer = provider.getSigner();

  const select = document.getElementById('winner_id');
  const winnerAddress = select.value;
  const abi = [
    {
      inputs: [
        {
          internalType: 'address payable',
          name: '_winner',
          type: 'address'
        }
      ],
      name: 'resolveDispute',
      outputs: [],
      stateMutability: 'nonpayable',
      type: 'function'
    }
  ];

  const contract = new ethers.Contract(address, abi, signer);

  try {
    await contract.resolveDispute(winnerAddress);
  } catch (error) {
    alert(error.data.message);
  }
}
