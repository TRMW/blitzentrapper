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
    return <li className="setlist__track"
               ref={this.props.draggableRef}
               {...this.props.draggableProps}>
      <div className="setlist__track__position">
        {this.props.index + 1}.
      </div>
      {this.state.showWriteIn ? (
        <SongInput index={this.props.index}
                   writeInSetlistingSong={this.props.writeInSetlistingSong} />
      ) : (
        <SongSelector index={this.props.index}
                      setlisting={this.props.setlisting}
                      allSongs={this.props.allSongs}
                      selectSetlistingSong={this.props.selectSetlistingSong} />
      )}
      <a className="setlist__track__action"
         onClick={this.toggleWriteIn}>
        {this.state.showWriteIn ? "select" : "write in"}
      </a>
      <div className="setlist__track__drag" {...this.props.dragHandleProps}>
        drag
      </div>
    </li>
  }
}

export default SongEditor;
