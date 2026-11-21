import { afterEach, describe, expect, it, vi } from "vitest";
import { cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import Setlist from "../../app/javascript/setlist/Setlist";

const songs = [ { id: 1, title: "Furr" }, { id: 2, title: "Black River Killer" } ];
const show = {
  id: 7,
  encore: 1,
  setlistings: [
    { id: 11, position: "1", song_id: 1, song: songs[0] },
    { id: 12, position: "2", song_id: 2, song: songs[1] },
    { id: "temp_1", position: "3", song_id: null, song: null },
  ],
};

afterEach(() => {
  cleanup();
  vi.unstubAllGlobals();
});

describe("Setlist", () => {
  it("shows the tracks and the encore to visitors", () => {
    render(<Setlist initialShow={show} allSongs={songs} signedIn={false} />);
    expect(screen.getByText("Furr")).toBeTruthy();
    expect(screen.getByText("Encore")).toBeTruthy();
    expect(screen.queryByText("Edit")).toBeNull();
  });

  it("lets a signed-in user pick a song and save", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, json: async () => ({ status: true }) });
    vi.stubGlobal("fetch", fetchMock);

    render(<Setlist initialShow={show} allSongs={songs} signedIn={true} />);
    fireEvent.click(screen.getByText("Edit"));

    const selects = screen.getAllByRole("combobox");
    expect(selects).toHaveLength(3);
    fireEvent.change(selects[2], { target: { value: "1" } });
    fireEvent.click(screen.getByText("Save Setlist"));

    await waitFor(() => expect(screen.getByText("Edit")).toBeTruthy());
    const [ url, options ] = fetchMock.mock.calls[0];
    expect(url).toBe("/shows/7");
    expect(options.method).toBe("PUT");
    const sent = JSON.parse(options.body).show;
    expect(sent.encore).toBe(1);
    expect(sent.setlistings[2]).toMatchObject({ id: "temp_1", song_id: 1 });
    expect(screen.getAllByText("Furr")).toHaveLength(2);
  });

  it("keeps the editor open and shows an error when saving fails", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
      ok: true,
      json: async () => ({ status: 422, errors: [ "Venue can't be blank" ] }),
    }));

    render(<Setlist initialShow={show} allSongs={songs} signedIn={true} />);
    fireEvent.click(screen.getByText("Edit"));
    fireEvent.click(screen.getByText("Save Setlist"));

    await waitFor(() => expect(screen.getByText(/Venue can't be blank/)).toBeTruthy());
    expect(screen.getByText("Save Setlist")).toBeTruthy();
  });
});
