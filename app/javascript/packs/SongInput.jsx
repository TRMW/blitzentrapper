import React from 'react';
import { Component } from 'react';

class SongSelector extends Component {
  render() {
    return <input type="text" onInput={(e) => this.props.writeInSetlistingSong(this.props.index, e.target.value)} />
  }
}

export default SongSelector;
