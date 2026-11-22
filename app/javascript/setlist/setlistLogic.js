// Pure helpers for the setlist editor and display, kept free of React so
// they can be unit tested (see test/javascript/setlistLogic.test.js).
//
// `encore` is the number of tracks played before the encore, i.e. the
// encore divider sits after track number `encore` (1-indexed). In the
// editor's drag list the divider is a pseudo-item inserted at that index.

export const ENCORE_ID = "encore";

// The editor's drag list: the setlistings with the encore divider inserted.
export function buildDraggables(setlistings, encore) {
  const draggables = [ ...setlistings ];
  draggables.splice(encore, 0, { id: ENCORE_ID, isEncore: true });
  return draggables;
}

// Moves the item at `sourceIndex` of the drag list to `destinationIndex`
// (both indices include the encore divider) and returns the new setlistings,
// renumbered from 1, and the new encore position.
export function moveDraggable(setlistings, encore, sourceIndex, destinationIndex) {
  const draggables = buildDraggables(setlistings, encore);
  const [ moved ] = draggables.splice(sourceIndex, 1);
  draggables.splice(destinationIndex, 0, moved);

  const newEncore = draggables.findIndex((item) => item.isEncore);
  const reordered = draggables
    .filter((item) => !item.isEncore)
    .map((setlisting, i) => ({ ...setlisting, position: String(i + 1) }));

  return { setlistings: reordered, encore: newEncore };
}

// Picks a song from the dropdown. An empty id clears the slot.
export function selectSong(setlisting, songId, allSongs) {
  if (songId === "" || songId === null || songId === undefined) {
    return { ...setlisting, song_id: null, song: undefined };
  }
  const id = Number(songId);
  return { ...setlisting, song_id: id, song: allSongs.find((song) => song.id === id) };
}

// Titles compare ignoring case and extra spaces (same rule as Song.matching_title).
const normalizeTitle = (title) => (title ?? "").trim().replace(/\s+/g, " ").toLowerCase();

// A typed-in song. If it matches a song already in the list, that song is
// selected so no duplicate is created; otherwise the server creates it.
export function writeInSong(setlisting, title, allSongs = []) {
  const normalized = normalizeTitle(title);
  const existing = normalized && allSongs.find((song) => normalizeTitle(song.title) === normalized);
  if (existing) {
    return { ...setlisting, song_id: existing.id, song: existing };
  }
  return { ...setlisting, song_id: null, song: { title } };
}

// The tracks to show on the public setlist: blank slots are skipped (a
// write-in has a song title but no song_id until saved) and
// tracks are numbered consecutively. Returns the tracks plus how many of
// them come before the encore divider (null when no divider should show,
// i.e. when the encore would be empty or would hold the whole set).
export function displayTracks(setlistings, encore) {
  const tracks = setlistings.filter((setlisting) => setlisting.song?.title);
  const before = tracks.filter((setlisting) => Number(setlisting.position) <= encore).length;
  return {
    tracks,
    encoreAfter: before > 0 && before < tracks.length ? before : null,
  };
}
