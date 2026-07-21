import React from 'react';
import { Component } from 'react';
import { createRoot } from 'react-dom/client';
import SetlistEditor from './SetlistEditor';
import SetlistDisplay from './SetlistDisplay';
import axios from 'axios';

class Setlist extends Component {
  constructor(props) {
    super(props);
    this.state = {
      show: this.props.show,
      shouldShowEditor: false
    };
    this.showSetListEditor = this.showSetListEditor.bind(this);
    this.hideSetListEditor = this.hideSetListEditor.bind(this);
    this.saveSetlistings = this.saveSetlistings.bind(this);
  }

  showSetListEditor() {
    this.setState({ shouldShowEditor: true });
  }

  hideSetListEditor() {
    this.setState({ shouldShowEditor: false });
  }

  // Mirrors the controller's build_setlistings_attributes logic to adjust
  // encore position before sending. Filters out untouched temporary blanks
  // and maps the encore position from original indices to filtered indices.
  adjustEncorePosition(setlistings, encorePosition) {
    const keptIndices = [];
    
    setlistings.forEach((setlisting, index) => {
      const id = setlisting.id;
      const hasRealId = id && !id.toString().startsWith('_');
      const hasSong = setlisting.song_id || (setlisting.song && setlisting.song.title);
      
      // Keep existing records or new records with actual songs
      if (hasRealId || hasSong) {
        keptIndices.push(index);
      }
    });

    // Map the encore position from original indices to filtered indices
    if (encorePosition !== null && encorePosition !== undefined) {
      const adjustedIndex = keptIndices.indexOf(encorePosition);
      if (adjustedIndex !== -1) {
        return adjustedIndex;
      }
      
      // If encore pointed to a filtered-out item, find the closest kept item at or after
      for (let i = 0; i < keptIndices.length; i++) {
        if (keptIndices[i] > encorePosition) {
          return i;
        }
      }
      
      // If no item found after, use the last kept item
      return keptIndices.length > 0 ? keptIndices.length - 1 : 0;
    }
    
    return encorePosition;
  }

  saveSetlistings(updatedSetlistings, updatedEncore) {
    const updatedShow = Object.assign({}, this.state.show)
    
    // Adjust encore position before sending to match what the controller will do
    const adjustedEncore = this.adjustEncorePosition(updatedSetlistings, updatedEncore);
    
    updatedShow.setlistings = updatedSetlistings;
    updatedShow.encore = adjustedEncore;
    const csrfToken = document.querySelector('meta[name=csrf-token]').content;
    axios.put(
        `/shows/${this.props.show.id}`,
        { show: updatedShow },
        {
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrfToken,
            'X-Requested-With': 'XMLHttpRequest'
          }
        }
      )
      .then(response => {
        this.setState({ show: updatedShow });
        this.hideSetListEditor();
      })
  }

  render() {
    if (this.props.show.setlistings.length) {
      if (this.state.shouldShowEditor) {
        return <SetlistEditor show={this.state.show}
                              allSongs={this.props.allSongs}
                              hideSetListEditor={this.hideSetListEditor}
                              save={this.saveSetlistings} />
      } else {
        return <SetlistDisplay show={this.state.show}
                               allSongs={this.props.allSongs}
                               showSetListEditor={this.showSetListEditor}
                               signedIn={this.props.signedIn} />
      }
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const show = JSON.parse(document.querySelector('meta[name="blitzen-setlist-data-show"]').content);
  const allSongs = JSON.parse(document.querySelector('meta[name="blitzen-setlist-data-all-songs"]').content);
  const signedIn = JSON.parse(document.querySelector('meta[name="blitzen-setlist-data-signed-in"]').content === 'true');

  const setlist = document.querySelector('.setlist');
  const root = createRoot(setlist);
  root.render(<Setlist show={show} allSongs={allSongs} signedIn={signedIn} />);
})

