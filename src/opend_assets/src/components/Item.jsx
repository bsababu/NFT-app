import React, { useEffect, useState } from "react";
import logo from "../../assets/logo.png";
import { Actor, HttpAgent } from "@dfinity/agent";
import { idlFactory } from "../../../declarations/nft/";
import { Principal } from "@dfinity/principal";
import Button from "./Button";
import { opend } from "../../../declarations/opend";
function Item(props) {
  const [name, setName] = useState();
  const [owner, setOwner] = useState();
  const [images, setImage] = useState();
  const [button, setButton] = useState();
  const [priceInput, setPriceInput] = useState();
  // const id = Principal.fromText(props.id);
  const id = props.id;

  const localHost = "http://localhost:8080/";
  const agent = new HttpAgent({ host: localHost });
  agent.fetchRootKey(); // to keep running locally, but remove it when deploying online
  let NFTactor;
  async function loadNft() {
    NFTactor = await Actor.createActor(idlFactory, {
      agent,
      canisterId: id,
    });

    const name = await NFTactor.getName();
    const owner = await NFTactor.getOwner();
    const imageAsset = await NFTactor.getAsset();
    const imgCont = new Uint8Array(imageAsset);
    const img = URL.createObjectURL(
      new Blob([imgCont.buffer], { type: "image/png" })
    );

    setName(name);
    setOwner(owner.toText());
    setImage(images);
    setButton(<Button handleClick={handleSell} text="Sell" />);
  }
  useEffect(() => {
    loadNft();
  }, []);
  let price;
  function handleSell() {
    console.log("button clicked");
    setPriceInput(
      <input
        placeholder="Price in SBB"
        type="number"
        className="price-input"
        value={price}
        onChange={(e) => e.target.value}
      />
    );
    setButton(<Button handleClick={sellItem} text={"Confirm"} />);
  }
  async function sellItem() {
    console.log("sold out" + price);
    const result = await opend.listItem(props.id, Number(price));
    console.log(result);
    if ( result == "success") {
      const transferRes = await NFTactor.transferOwnership(await opend.getOpenedCannisterId());

    }
  }
  
  return (
    <div className="disGrid-item">
      <div className="disPaper-root disCard-root makeStyles-root-17 disPaper-elevation1 disPaper-rounded">
        <img
          src={images}
          className="disCardMedia-root makeStyles-image-19 disCardMedia-media disCardMedia-img"
        />
        <div className="disCardContent-root">
          <h2 className="disTypography-root makeStyles-bodyText-24 disTypography-h5 disTypography-gutterBottom">
            name: {name}
            <span className="purple-text"></span>
          </h2>
          <p className="disTypography-root makeStyles-bodyText-24 disTypography-body2 disTypography-colorTextSecondary">
            Owner: {owner}
          </p>
          {priceInput}
          {button}
        </div>
      </div>
    </div>
  );
}

export default Item;
