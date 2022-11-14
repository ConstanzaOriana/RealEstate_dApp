const { expect } = require('chai');
const { ethers } = require('hardhat');

const tokens = (n) => {
    //we've got ethers pulled in uh we have a helper here that helps convert currency to tokens all right and 
    //then we have this function called describe('escrow' where we're going to put all the tests for the escrow smart contract itself 
    return ethers.utils.parseUnits(n.toString(), 'ether')
}

describe('Escrow', () => {
    })      