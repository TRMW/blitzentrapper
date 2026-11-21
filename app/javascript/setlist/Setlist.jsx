import { useState } from "react";
import SetlistEditor from "./SetlistEditor";
import SetlistDisplay from "./SetlistDisplay";

async function saveSetlist(showId, setlistings, encore) {
  const csrfToken = document.querySelector("meta[name=csrf-token]")?.content;
  const response = await fetch(`/shows/${showId}`, {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "X-CSRF-Token": csrfToken,
      "X-Requested-With": "XMLHttpRequest",
    },
    body: JSON.stringify({ show: { setlistings, encore } }),
  });
  const data = response.ok ? await response.json() : null;
  // The controller answers validation failures with HTTP 200 and
  // { status: 422, errors: [...] }.
  if (!data || data.status === 422) {
    throw new Error(data?.errors?.join(", ") || `HTTP ${response.status}`);
  }
}

// Shows the setlist, and lets signed-in users switch to the editor.
export default function Setlist({ initialShow, allSongs, signedIn }) {
  const [ show, setShow ] = useState(initialShow);
  const [ editing, setEditing ] = useState(false);

  if (show.setlistings.length === 0) return null;

  // The server drops untouched blank slots and remaps the encore position
  // (ShowsController#build_setlistings_attributes), so we send every slot.
  async function save(setlistings, encore) {
    await saveSetlist(show.id, setlistings, encore);
    setShow({ ...show, setlistings, encore });
    setEditing(false);
  }

  if (editing) {
    return (
      <SetlistEditor
        show={show}
        allSongs={allSongs}
        onCancel={() => setEditing(false)}
        onSave={save}
      />
    );
  }

  return (
    <SetlistDisplay show={show} signedIn={signedIn} onEdit={() => setEditing(true)} />
  );
}
