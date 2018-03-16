// Copyright (c) 2013-2015 The Bitcoin sCrypt developers
// Copyright (c) 2009-2013 The Bitcoin developers
// Copyright (c) 2011-2012 The Litecoin developers
// Distributed under the MIT/X11 software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include <boost/assign/list_of.hpp> // for 'map_list_of()'
#include <boost/foreach.hpp>

#include "checkpoints.h"

#include "main.h"
#include "uint256.h"

namespace Checkpoints
{
    typedef std::map<int, uint256> MapCheckpoints;

    //
    // What makes a good checkpoint block?
    // + Is surrounded by blocks with reasonable timestamps
    //   (no blocks before with a timestamp after, none after with
    //    timestamp before)
    // + Contains no strange transactions
    //
    static MapCheckpoints mapCheckpoints =
        boost::assign::map_list_of // Yo dawg, this is the secret. Checkpoint 0 hash == Genesis block hash.
        (         0, uint256("0x238e46f9222a2fdb20fde8ed5aee78d6b5e0f0d38d2ace3ceb5ebd6d00d99ae9"))
        (	  11111, uint256("0x991b5a7f1d6474fb9621648d846d5e1ee6ff96caaad61172e93afe9d0bca88ba"))
        (	  33333, uint256("0xd86a7328bd76cfcef80206f87cbab7059fc1ba0de9a958a34196cb69ed9b49dd"))
        (	  55555, uint256("0x91a97f084e949c386623c28de52f8ca0ddb4219fd8df41405e26050796fe9161"))
        (	  60000, uint256("0xc0cd1649dc6b3e1e8d9a7757d1587e7511f5e79a6dcf7dbf0ca49380b58ba587"))
        (	  70000, uint256("0x4f98d6f1949c463e2523fa80a2ab31d3311f39eb8be59306f49576f907d82e79"))
        (	  80000, uint256("0xd84faceed64baff113986a32bab8578e899f79974069dc9dcaefafacc458483e"))
        (	  90000, uint256("0x44ab6e2b7afefd3965f520d9ef61cc5237970c54b3d637731c95e8021dfb064c"))
        (	  95000, uint256("0x8a641977f7f1f7ac9e75901897eb3f260f8ea00e181f6e4e2fdf41a2b506629d"))
        (	  96000, uint256("0xc13fbb99636c34d595663c32d5fd357452f086da7470061402e1ac4a6e52cd2f"))
        (	  96050, uint256("0x45300e7b103ee9c15c89b457e5cfe62b7bec220d7aca42c616efd0c7b0355948"))
	(	  100000, uint256("0x0cff44d5209c9bdc0b034f9f64091552a870df2009fdd8a1686ad1187ca0c8b3"))
	(	  200000, uint256("0xe5a47745a95136a4c6edbc4a6b414ad047bc440d22ce8078131f517637528b88"))
	(	  300000, uint256("0x60fc17ab0599ca9cacf5ea99648ef21fedc9101aba1e6484e75ae6fa4f09f7af"))
	(	  303900, uint256("0x15a45618f2adca385f04826e2aeebfb5f664e58734db577a3d5cbb7126a294cf"))
	(	  323000, uint256("0x8277801a42c75927d3b3a662753b3c6bf5f08a32bc3bdfab1537287cc6fb918d"))
						;

    bool CheckBlock(int nHeight, const uint256& hash)
    {
        if (fTestNet) return true; // Testnet has no checkpoints

        MapCheckpoints::const_iterator i = mapCheckpoints.find(nHeight);
        if (i == mapCheckpoints.end()) return true;
        return hash == i->second;
    }
    
    int GetTotalBlocksEstimate()
    {
        if (fTestNet) return 0;
        
        // 1. Initialization:
        //    Actual block height cannot be fetched accurately during syncing, unless we could fetch it
        //    from a tursted and up-to-date Block explorer. So we make an educated guess as follows:
        //    Bitcoin-Scrypt made a hard fork on 19/02/2018, the very first block on that day is:
        //      block     : fc65e9325c8e90cf2154a128a92e09bbe2350ae17f7368effec4e9e9c37d6f51
        //      height    : 496568
        //      timestamp : 19th Feb 2018 00:01:45 GMT
        //      Epoch time: 1518998505 sec. since 1970
        //    Take an average of 180 sec per block and add it to the reference block height as an initial value
        //
        static int estimatedNumOfBlocks = 0;
        static const int forkedHeight = 496568;
        static const int forkedEpochTime = 1518998505;
        if (estimatedNumOfBlocks < forkedHeight){
            int64 now = GetTimeMillis();
            estimatedNumOfBlocks = forkedHeight + (now/1000 - forkedEpochTime) / 180;
        }
        
        // Check for connected Peers
        if (vNodes.size() != 0){
            // 2. Adjust estimation to other Peers max block height
            int numOfBlocksAverageFromConnectedPeers = GetMaxNumOfBlocksFromConnectedPeers();
            if (numOfBlocksAverageFromConnectedPeers > forkedHeight){
                estimatedNumOfBlocks = numOfBlocksAverageFromConnectedPeers;
            }
            
            // 3. pindexBest is the current block during syncing or last db loaded block
            if (pindexBest != NULL){
                int nHeight = pindexBest->nHeight;
                bool topOfBlockchainReached = (pindexBest->pnext == NULL);
                if (topOfBlockchainReached){
                    // Last block of the blockchain reached.
                    estimatedNumOfBlocks = nHeight;
                } else if (nHeight >= estimatedNumOfBlocks){
                    // Not yet fully synced, keep estimation heigher then current parsed height
                    estimatedNumOfBlocks = nHeight + 1;
                }
            }
        }
        return estimatedNumOfBlocks;
    }

    CBlockIndex* GetLastCheckpoint(const std::map<uint256, CBlockIndex*>& mapBlockIndex)
    {
        if (fTestNet) return NULL;

        BOOST_REVERSE_FOREACH(const MapCheckpoints::value_type& i, mapCheckpoints)
        {
            const uint256& hash = i.second;
            std::map<uint256, CBlockIndex*>::const_iterator t = mapBlockIndex.find(hash);
            if (t != mapBlockIndex.end())
                return t->second;
        }
        return NULL;
    }
}
