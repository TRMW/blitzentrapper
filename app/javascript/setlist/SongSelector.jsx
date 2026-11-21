// Dropdown of every known song.
export default function SongSelector({ setlisting, allSongs, onSelectSong }) {
  return (
    <select value={setlisting.song_id ?? ""} onChange={(e) => onSelectSong(e.target.value)}>
      <option value="">Select a song</option>
      {allSongs.map((song) => (
        <option key={song.id} value={song.id}>{song.title}</option>
      ))}
    </select>
  );
}
