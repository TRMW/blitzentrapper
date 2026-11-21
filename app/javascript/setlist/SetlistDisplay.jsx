import { Fragment } from "react";
import { displayTracks } from "./setlistLogic";

// The public, read-only setlist.
export default function SetlistDisplay({ show, signedIn, onEdit }) {
  const { tracks, encoreAfter } = displayTracks(show.setlistings, show.encore);

  if (tracks.length === 0 && !signedIn) return <div />;

  return (
    <div>
      <div className="setlist__header">
        <div className="setlist__header__title">Setlist</div>
        {signedIn && (
          <a className="setlist__header__action" onClick={onEdit}>
            {tracks.length ? "Edit" : "Add"}
          </a>
        )}
      </div>
      {tracks.length > 0 && (
        <div className="setlist__tracks">
          <ul>
            {tracks.map((setlisting, i) => (
              <Fragment key={setlisting.id}>
                {/* Numbered by index, not position, so blank slots collapse. */}
                <li className="setlist__track">
                  <div className="setlist__track__position">{i + 1}.</div>
                  <div className="setlist__track__display-title">{setlisting.song.title}</div>
                </li>
                {i + 1 === encoreAfter && (
                  <div className="setlist__encore-display">Encore</div>
                )}
              </Fragment>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}
