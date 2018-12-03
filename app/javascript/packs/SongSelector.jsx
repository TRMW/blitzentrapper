import React from 'react';
import { Component } from 'react';

class SongSelector extends Component {
  render() {
    const options = this.props.allSongs.map((song) =>
      <option key={`song-selector-${this.props.setlisting.id}-${song.id}`}
              value={song.id}>
        {song.title}
      </option>
    )

    options.unshift(<option key={`song-selector-${this.props.setlisting.id}-blank`} value=''>Select a song</option>)

    return <select defaultValue={this.props.setlisting.song_id}
                   onChange={(e) => this.props.selectSetlistingSong(this.props.setlisting, e.target.value)}>
      {options}
    </select>
  }
}

export default SongSelector;
