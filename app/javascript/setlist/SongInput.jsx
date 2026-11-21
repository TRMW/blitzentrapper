// Free-text title for a song that isn't in the song list.
export default function SongInput({ onWriteIn }) {
  return <input type="text" onChange={(e) => onWriteIn(e.target.value)} />;
}
