import React from 'react';
import PropTypes from 'prop-types';
import { Component } from 'react';

class SongInput extends Component {
  render() {
    return <input type="text" onInput={(e) => this.props.writeInSetlistingSong(this.props.index, e.target.value)} />
  }
}

SongInput.propTypes = {
  index: PropTypes.number.isRequired,
  writeInSetlistingSong: PropTypes.func.isRequired,
};

export default SongInput;
