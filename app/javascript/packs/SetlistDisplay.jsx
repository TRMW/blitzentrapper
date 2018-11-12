import React from 'react';
import { Component } from 'react';

class SetlistDisplay extends Component {
  render() {
    let songs = [];

    this.props.show.setlistings.forEach((setlisting, i) => {
      if (setlisting.song) {
        songs.push(<li className="setlist__track" key={setlisting.id}>
          <div className="setlist__track__position">
            {i + 1}.
          </div>
          <div className="setlist__track__display-title">
            {setlisting.song.title}
          </div>
        </li>)
      }
    })

    // This has the weird effect of making it so Encore div doesn't display if
    // there are blank tracks before the encore :(
    // Maybe we can make it so blank setlistings aren't created on Show create,
    // then we could just check setlistings length and now there aren't a bunch
    // of blank songs in there
    if (songs.length > this.props.show.encore) {
      songs.splice(this.props.show.encore, 0, <div key="encore" className="setlist__encore-display">Encore</div>);
    }

    return <div>
      <div className="setlist__header">
        <div className="setlist__header__title">
          Setlist
        </div>
        <a className="setlist__header__action"
           onClick={this.props.showSetListEditor}>
          {songs.length ? 'Edit' : 'Add'}
        </a>
      </div>
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
