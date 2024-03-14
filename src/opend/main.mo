import Principal "mo:base/Principal";
import Cycles "mo:base/ExperimentalCycles";
import Text "mo:base/Text";
import Nat8 "mo:base/Nat8";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import List "mo:base/List";
import Nat "mo:base/Nat";
import NFTActorClass "../NFT/nft"

actor OpenD {

    private type Listing = {
        itemOwner: Principal;
        itemPrice: Nat;
    };
    
    var mapOfNFTs = HashMap.HashMap<Principal, NFTActorClass.NFT>(1, Principal.equal, Principal.hash);
    var mapOfOwners = HashMap.HashMap<Principal, List.List<Principal>>(1, Principal.equal, Principal.hash);
    var mapOfListings = HashMap.HashMap<Principal, Listing>(1, Principal.equal, Principal.hash);


    public shared(msg) func mint(imgData:[Nat8], name:Text): async Principal {

        let owner: Principal = msg.caller;
        Debug.print(debug_show(Cycles.balance()));
        Cycles.add(100_500_000_000);
        // Debug.print(debug_show(Cycles.balance()));
        let newNFT = await NFTActorClass.NFT(name, owner, imgData);
        Debug.print(debug_show(Cycles.balance()));
        let newNFTPrincipal = await newNFT.getCannisterId();
        mapOfNFTs.put(newNFTPrincipal,newNFT);
        addToOwnershipMap(owner, newNFTPrincipal);
        return newNFTPrincipal;
    };

    // hold of before pushing to a list
    private func addToOwnershipMap(owner: Principal, nftid:Principal) {
        var ownedNFTs: List.List<Principal> = switch(mapOfOwners.get(owner)){
            case null List.nil<Principal>();
            case (?result) result;
        };

        ownedNFTs := List.push(nftid,ownedNFTs);
        mapOfOwners.put(owner, ownedNFTs)
    };

    // bring this to frontEnd

    public query func getOwnedNFTs(user: Principal): async [Principal] {
        var userNFTs: List.List<Principal> = switch (mapOfOwners.get(user)) {
            case null List.nil<Principal>();
            case (?result) result;
        };

        return List.toArray(userNFTs);
    };

    public shared(msg) func listItem(id: Principal, price: Nat): async Text{
        var item: NFTActorClass.NFT = switch(mapOfNFTs.get(id)){
            case null return "No NFT in bank";
            case (?result) result;
        };
        let owner = await item.getOwner();

        if(Principal.equal(owner, msg.caller)) {
            let newListing : Listing ={
                itemOwner= owner;
                itemPrice= price;
            };
            mapOfListings.put(id, newListing);
            return "success";
        } else {
            return "get more NFTS";
        };
    };

    public query func getOpenedCannisterId(): async Principal {
        return Principal.fromActor(OpenD);
    }
};
