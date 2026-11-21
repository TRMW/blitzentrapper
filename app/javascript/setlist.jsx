// Entry point for the setlist widget on the show page
// (app/views/shows/show.html.erb). esbuild bundles it into
// app/assets/builds/setlist.js; see the "build" script in package.json.
import { createRoot } from "react-dom/client";
import Setlist from "./setlist/Setlist";

function readMeta(name) {
  return document.querySelector(`meta[name="${name}"]`)?.content;
}

function mount() {
  const container = document.querySelector(".setlist");
  if (!container) return;

  const show = JSON.parse(readMeta("blitzen-setlist-data-show"));
  const allSongs = JSON.parse(readMeta("blitzen-setlist-data-all-songs"));
  const signedIn = readMeta("blitzen-setlist-data-signed-in") === "true";

  createRoot(container).render(
    <Setlist initialShow={show} allSongs={allSongs} signedIn={signedIn} />
  );
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", mount);
} else {
  mount();
}
