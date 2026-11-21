import { describe, expect, it } from "vitest";
import {
  buildDraggables,
  displayTracks,
  moveDraggable,
  selectSong,
  writeInSong,
} from "../../app/javascript/setlist/setlistLogic";

const song = (id, title) => ({ id, title });
const slot = (id, position, s = null) => ({ id, position: String(position), song_id: s?.id ?? null, song: s });

const A = song(1, "Furr");
const B = song(2, "Black River Killer");
const C = song(3, "God and Suicide");
const D = song(4, "Wild Mountain Nation");

const set = () => [ slot(11, 1, A), slot(12, 2, B), slot(13, 3, C) ];
const titles = (setlistings) => setlistings.map((s) => s.song.title);

describe("buildDraggables", () => {
  it("inserts the encore divider after track number `encore`", () => {
    const ids = buildDraggables(set(), 2).map((item) => item.id);
    expect(ids).toEqual([ 11, 12, "encore", 13 ]);
  });
});

describe("moveDraggable", () => {
  it("moves the encore divider", () => {
    // [A, B, |E|, C] -> drag E to index 1 -> [A, E, B, C]
    const result = moveDraggable(set(), 2, 2, 1);
    expect(result.encore).toBe(1);
    expect(titles(result.setlistings)).toEqual([ "Furr", "Black River Killer", "God and Suicide" ]);
  });

  it("moves an encore song into the main set", () => {
    // [A, B, |E|, C] -> drag C to the top -> [C, A, B, E]
    const result = moveDraggable(set(), 2, 3, 0);
    expect(titles(result.setlistings)).toEqual([ "God and Suicide", "Furr", "Black River Killer" ]);
    expect(result.encore).toBe(3);
  });

  it("moves a main-set song into the encore", () => {
    // [A, B, |E|, C] -> drag A to the bottom -> [B, E, C, A]
    const result = moveDraggable(set(), 2, 0, 3);
    expect(titles(result.setlistings)).toEqual([ "Black River Killer", "God and Suicide", "Furr" ]);
    expect(result.encore).toBe(1);
  });

  it("reorders within the main set without moving the encore", () => {
    // [A, B, |E|, C] -> swap A and B
    const result = moveDraggable(set(), 2, 1, 0);
    expect(titles(result.setlistings)).toEqual([ "Black River Killer", "Furr", "God and Suicide" ]);
    expect(result.encore).toBe(2);
  });

  it("renumbers positions from 1 and leaves the input untouched", () => {
    const original = set();
    const result = moveDraggable(original, 2, 3, 0);
    expect(result.setlistings.map((s) => s.position)).toEqual([ "1", "2", "3" ]);
    expect(original.map((s) => s.position)).toEqual([ "1", "2", "3" ]);
    expect(original[0].song).toBe(A);
  });
});

describe("selectSong / writeInSong", () => {
  it("picks a song by id", () => {
    const updated = selectSong(slot(11, 1), "4", [ A, D ]);
    expect(updated.song_id).toBe(4);
    expect(updated.song).toBe(D);
  });

  it("clears the slot for an empty id", () => {
    const updated = selectSong(slot(11, 1, A), "", [ A ]);
    expect(updated.song_id).toBeNull();
    expect(updated.song).toBeUndefined();
  });

  it("sets a write-in title without a song id", () => {
    const updated = writeInSong(slot(11, 1, A), "New Song");
    expect(updated).toMatchObject({ song_id: null, song: { title: "New Song" } });
  });
});

describe("displayTracks", () => {
  it("skips blank slots and places the encore after the right track", () => {
    const setlistings = [ slot(11, 1, A), slot("temp_1", 2), slot(12, 3, B), slot(13, 4, C) ];
    const { tracks, encoreAfter } = displayTracks(setlistings, 3);
    expect(titles(tracks)).toEqual([ "Furr", "Black River Killer", "God and Suicide" ]);
    expect(encoreAfter).toBe(2);
  });

  it("hides the divider when there is no encore", () => {
    expect(displayTracks(set(), null).encoreAfter).toBeNull();
    expect(displayTracks(set(), 3).encoreAfter).toBeNull();
  });

  it("shows unsaved write-ins", () => {
    const { tracks } = displayTracks([ writeInSong(slot("temp_1", 1), "New Song") ], 0);
    expect(titles(tracks)).toEqual([ "New Song" ]);
  });
});
