import { useState } from "react";
import SongSelector from "./SongSelector";
import SongInput from "./SongInput";

// One draggable track in the editor: pick a song, or type a write-in.
export default function SongEditor({
  setlisting,
  allSongs,
  innerRef,
  draggableProps,
  dragHandleProps,
  onSelectSong,
  onWriteIn,
}) {
  const [ showWriteIn, setShowWriteIn ] = useState(false);

  return (
    <li className="setlist__track" ref={innerRef} {...draggableProps}>
      <div className="setlist__track__position">{setlisting.position}.</div>
      {showWriteIn ? (
        <SongInput onWriteIn={onWriteIn} />
      ) : (
        <SongSelector setlisting={setlisting} allSongs={allSongs} onSelectSong={onSelectSong} />
      )}
      <a className="setlist__track__action" onClick={() => setShowWriteIn(!showWriteIn)}>
        {showWriteIn ? "select" : "write in"}
      </a>
      <div className="setlist__track__drag" {...dragHandleProps}>
        drag
      </div>
    </li>
  );
}
