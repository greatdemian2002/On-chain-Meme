📄 README for On-chain Meme Factory Smart Contract

Overview

The On-chain Meme Factory is a Clarity smart contract deployed on the Stacks blockchain that allows users to mint unique meme NFTs tied to trending keywords. The contract integrates meme creation with dynamic popularity scores, making memes not just collectibles but also reflections of real-time cultural trends.

✨ Features

NFT Minting: Users can mint meme NFTs with a title, image URL, and trending keyword.

Dynamic Popularity: Meme NFTs are associated with a trending score based on the selected keyword.

Ownership Tracking: Each meme NFT’s ownership is recorded on-chain, ensuring transparency and security.

Transfer Functionality: NFT owners can transfer their memes to others.

Admin Controls:

Update trending keyword popularity scores.

Toggle minting (enable/disable NFT creation).

Read-Only Queries:

Get meme metadata by ID.

Fetch meme owner.

Retrieve keyword popularity.

Check minting status and next meme ID.

Count total memes minted.

⚙️ Data Structures

meme-data: Stores meme metadata (creator, title, image URL, score, timestamp).

meme-owners: Tracks the current owner of each meme NFT.

trending-keywords: Stores popularity scores and update timestamps for trending terms.

🛠️ Usage

Mint a Meme

(contract-call? .meme-factory mint-meme "When BTC pumps" "https://meme-url.com/btc.jpg" "bitcoin")


Update Trending Keyword (Admin)

(contract-call? .meme-factory update-trending-keyword "bitcoin" u1000)


Transfer Meme

(contract-call? .meme-factory transfer-meme u1 tx-sender 'SPXXXXXX)


Check Meme Data

(contract-call? .meme-factory get-meme-data u1)

🔒 Errors

u100: Not authorized.

u101: Invalid meme data.

u102: Meme already exists.

u103: NFT not found.

📊 Example Flow

Admin updates trending keywords.

User mints a meme NFT tied to a keyword.

Ownership and metadata are stored on-chain.

Meme NFTs can be transferred and traded freely.