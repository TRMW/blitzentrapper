import React from 'react';
import { Component } from 'react';
import PropTypes from 'prop-types';
import ReactDOM from 'react-dom';
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

  saveSetlistings(updatedSetlistings, updatedEncore) {
    const updatedShow = Object.assign({}, this.state.show)
    updatedShow.setlistings = updatedSetlistings;
    updatedShow.encore = updatedEncore;
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
                               showSetListEditor={this.showSetListEditor} />
      }
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const show = JSON.parse(document.querySelector('meta[name="blitzen-setlist-data-show"').content);
  const allSongs = JSON.parse(document.querySelector('meta[name="blitzen-setlist-data-all-songs"').content);

  ReactDOM.render(
    <Setlist show={show} allSongs={allSongs} />,
    document.querySelector('.setlist')
  )
})
