import React from 'react';
import { Component } from 'react';

class SetlistDisplay extends Component {
  render() {
    let nonBlankSetlistings = [];
    let lastNonBlankSetlistingBeforeEncore;
    let songs = [];

    this.props.show.setlistings.forEach(setlisting => {
      if (setlisting.song_id !== null) {
        nonBlankSetlistings.push(setlisting);

        if (setlisting.position <= this.props.show.encore) {
          lastNonBlankSetlistingBeforeEncore = setlisting;
        }
      }
    });

    // NOTE: We intentionally use index for displayed track number, not position,
    // since we want to collapse blank setlistings.
    nonBlankSetlistings.forEach((setlisting, i) => {
      songs.push(<li className="setlist__track" key={setlisting.id}>
        <div className="setlist__track__position">
          {i + 1}.
        </div>
        <div className="setlist__track__display-title">
          {setlisting.song.title}
        </div>
      </li>)
    })

    if (lastNonBlankSetlistingBeforeEncore) {
      const lastNonBlankSetlistingBeforeEncoreIndex = nonBlankSetlistings.indexOf(lastNonBlankSetlistingBeforeEncore);
      // `encore` is the user-facing setlist position (*not* zero-indexed index)
      // of the last song *before* the encore, so we insert after
      songs.splice(lastNonBlankSetlistingBeforeEncoreIndex + 1, 0, <div key="encore" className="setlist__encore-display">Encore</div>);
    }

    return <div>
      {(songs.length > 0 || this.props.signedIn) &&
        <div className="setlist__header">
          <div className="setlist__header__title">
            Setlist
          </div>
          {this.props.signedIn &&
            <a className="setlist__header__action"
              onClick={this.props.showSetListEditor}>
              {songs.length ? 'Edit' : 'Add'}
            </a>
          }
        </div>
      }
      {songs.length > 0 &&
        <div className="setlist__tracks">
          <ul>
            {songs}
          </ul>
        </div>
      }
    </div>
  }
}

export default SetlistDisplay;
