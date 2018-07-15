import React from 'react';
import { Component } from 'react';
import SongSelector from './SongSelector';
import SongInput from './SongInput';

class SongEditor extends Component {
  constructor(props) {
    super(props);
    this.state = {
      showWriteIn: false
    };
    this.toggleWriteIn = this.toggleWriteIn.bind(this)
  }

  toggleWriteIn() {
    this.setState((prevState) => ({
      showWriteIn: !prevState.showWriteIn
    }));
  }

  render() {
    return <li ref={this.props.draggableRef} {...this.props.draggableProps}>
      {this.state.showWriteIn ? (
        <SongInput index={this.props.index}
                   writeInSetlistingSong={this.props.writeInSetlistingSong} />
      ) : (
        <SongSelector index={this.props.index}
                      setlisting={this.props.setlisting}
                      allSongs={this.props.allSongs}
                      selectSetlistingSong={this.props.selectSetlistingSong} />
      )}
      <span className="handle" {...this.props.dragHandleProps}>
         drag
       </span>
      <a className="edit-link"
         onClick={this.toggleWriteIn}>
        {this.state.showWriteIn ? "select" : "write in"}
      </a>
    </li>
  }
}

export default SongEditor;
