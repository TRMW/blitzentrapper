import React from 'react';
import { Component } from 'react';

class SetlistDisplay extends Component {
  render() {
    let songs;
    const hasSetlist = this.props.show.setlistings[0].song !== undefined;

    if (hasSetlist) {
      songs = this.props.show.setlistings.map((setlisting, i) =>
        setlisting.song && <li key={setlisting.id}>
          {setlisting.song.title}
        </li>
      )
      songs.splice(this.props.show.encore, 0, <div key="encore" className="encore-display">Encore</div>)
    }

    return <div>
      <div className="title">
        Setlist
        <a className="setlist_link"
           onClick={this.props.showSetListEditor}>
          {hasSetlist ? 'Edit' : 'Add'}
        </a>
      </div>
      {hasSetlist &&
        <div className="tracks">
          <ol>
            {songs}
          </ol>
        </div>
      }
    </div>
  }
}

export default SetlistDisplay;
