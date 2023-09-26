# Ethswarm

## Glossary

* *Proximity order (PO).* The length of the longest prefix common to two addresses (considered as bit strings). Up to some simple transformations, this can be interpreted as a 2-adic valuation. For example, consider the address as a bitstring prefixed with $0.$, it represents a rational number expanded in binary.

* *Neighbourhood of depth $d$*. A set of addresses having a common length $d$ prefix. A ball of $2$-adic radius $2^{-d}$ has depth $d$.

* *DISC reserve size.* The total size of all outstanding (non-expired) postage batches.

* *Reserve depth.* Rounded up base 2 logarithm of the reserve size. (Note h

  A quote that I don't understand (Book of Swarm, 3.3.4):

  > The base 2 logarithm of the DISC reserve size rounded up to the nearest integer is
  > called the reserve depth. The reserve depth is the shallowest PO such that disjoint
  > neighbourhoods of this depth are collectively able to accommodate the volume of
  > data corresponding to the total number of chunks paid for, assuming that nodes in
  > the neighbourhood have a fixed prescribed storage capacity to store their share of the
  > reserve.

  Questions.

  1. How is reserve depth related to the size of a node's reserve? (I think the latter is hardcoded to 16GB while the former is a dynamic quantity depending on usage.)
  2. A ball of depth $d$ has at least one expected chunk in its reserve if the reserve depth is at least $d$?

* *Storage depth.* From the way people use this, I believe this is the rounded up base 2 logarithm of the number of uploaded chunks on Swarm.

  The presentation in the Book of Swarm is very confusing and appears contradictory to common usage:

  > A node’s storage depth is defined as the shallowest complete bin, i.e., the lowest PO
  > that compliant reserves stores all batch bins at. Unless the farthest bin in the node’s
  > reserve is complete, the storage depth equals the reserve’s edge PO plus one.

* *Neighbourhood depth.* The depth of the smallest ball around a node $X$ that contains at least 3 other peers.

  Questions.

  1. What does it mean if storage depth equals neighbourhood depth? It means that each neighbourhood (containing at least 4 nodes) hosts at least one chunk in expectation. If each node hosts all chunks in its 4-node neighbourhood, then this guarantees an expected replication rate of at least 4.

* *Batch depth.* Base 2 logarithm of the number of postage stamps in a batch. (1 postage stamp goes on 1 chunk.)

* *Uniformity depth.* Base 2 logarithm of the number of buckets [of a batch]. Should be higher than storage depth, so that each bucket is always contained entirely within the area of responsibility of a node.

* *Postage batch* or *batch.* NFT that can be bought from the postage contract, representing the right to upload a particular number of chunks to each bucket.

* *Batch bin.* Relative to a given node, the set of all chunks of a particular distance and paid for with a particular postage batch.

* *Reserve.* Of a node $X$. A set of chunks $R$ satisfying the conditions:

  1. If $c\in R$ and $d(X,c') < d(X,c)$ then $c\in R$.
  2. If $c\in R$, $d(X,c) = d(X,c')$, and the balance remaining on the postage stamp attached to $c'$ exceeds that of $c$, then $c'\in R$.
  3. $R$ is maximal with respect to these conditions and $|R|<\mathrm{SIZE}$.

* *Reserve capacity.* The maximum size of the reserve, as hardcoded into the bee node. https://github.com/ethersphere/bee/blob/84b6eaad30b2823b61a141f21247e438ef101ac1/pkg/node/node.go#L177C8-L177C8

* *Proof of density.* Commitment to a reserve sample via the salted BMT hash of its chunks. The proof "contains information regarding the size of the set from which this was sampled." Comment: the sample is constructed by choosing the first $k$ chunks in the order implied by the lexicographic ordering of their salted hashes. Since the image of this hash ought to be uniformly distributed, if there are $M$ chunks in the sample then the $k$th hash should be $k/M$ of the way into the hash codomain (in expectation).

  Questions.

  1. Where is this defined formally?
  2. Where is it implemented?
  
* *Area of responsibility.* The neighbourhood of a node containing all batch bins of its reserve. (Also called *effective* area of responsibility (?)).

## Incentive structure

- https://medium.com/ethereum-swarm/the-a-b-c-of-the-swarm-incentives-c53525fb55d5
- Storage incentives paper is in the discord/research.

Redistribution game.

1. Each round, a neighbourhood is selected using some entropy. This is called the *neighbourhood selection anchor.*
2. All staked nodes in the selected neighbourhood may submit a "reserve commitment" to the chunks they store. This commitment is twisted by a secret that the node will reveal later.

## BZZ/PLUR

16 decimals.

questions
1. What is the role of dividing storage slots in a postage batch into buckets?
1a. In BoS \S3.3.1: "The referenced storage slot has the bucket specified and it aligns with
the chunk address stamped." Concretely, what are these two conditions? Can you point me to the location in the bee source code where these are validated?
1b. The field "storage slot" in the Stamp data structure comprises a bucket index and a storage slot index within the bucket.
https://github.com/ethersphere/bee/blob/master/pkg/postage/stamp.go

A. The chunk address determines the index of the bucket it should go into. Thus slots in a particular bucket are stored in the same neighbourhood. Slots within a bucket are fungible (at least before being filled), but buckets are not. 

This makes it expensive to fill up a single neighbourhood excessively.

Addresses:

- Token tracker (Ethereum). https://etherscan.io/token/0x19062190b1925b5b6689d7073fdfc8c2976ef8cb
- Token contract (Ethereum). https://etherscan.io/address/0x19062190b1925b5b6689d7073fdfc8c2976ef8cb
- Bonding curve (Ethereum). Frontend is Bzzaar. https://etherscan.io/address/0x4F32Ab778e85C4aD0CEad54f8f82F5Ee74d46904
  - 1M DAI collateral.
  - Check price here using `buyPrice(1)` query (result in cents).
- OpenBZZ exchange (Ethereum). Frontend openbzz.eth.limo. https://etherscan.io/address/0x69Defd0bdcDCA696042Ed75B00c10276c6D32A33
- Token tracker (Gnosis, bridged through Omnibridge). https://gnosisscan.io/token/0xdbf3ea6f5bee45c02255b2c26a16f300502f68da
- Omnibridge (GC). https://gnosisscan.io/address/0xf6a78083ca3e2a662d6dd1703c939c8ace2e268d

Storage incentives:

* Redistribution. https://gnosisscan.io/address/0x1F9a1FDe5c6350E949C5E4aa163B4c97011199B4
* Staking. https://gnosisscan.io/address/0x781c6D1f0eaE6F1Da1F604c6cDCcdB8B76428ba7

General information.

- Docs. https://docs.ethswarm.org/docs/learn/faq#what-is-plur

- Tokenomics. https://blog.ethswarm.org/hive/2021/bzz-tokenomics/

- Circulating supply feed. https://tokenservice.ethswarm.org/circulating_supply

  (Approx. 63M last time I checked.)

- Token sale. https://coinlist.co/swarm

- Price feed. https://tokenservice.ethswarm.org/token_price