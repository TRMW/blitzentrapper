import React from 'react';
import { Component } from 'react';
import { DragDropContext, Droppable, Draggable } from 'react-beautiful-dnd';
import SongEditor from './SongEditor';

// Ripped from https://codesandbox.io/s/k260nyxq9v
// a little function to help us with reordering the result
const reorder = (list, startIndex, endIndex) => {
  const result = Array.from(list);
  const [removed] = result.splice(startIndex, 1);
  result.splice(endIndex, 0, removed);
  return result;
};

class SetlistEditor extends Component {
  constructor(props) {
    super(props);
    this.state = {
      setlistings: this.props.show.setlistings,
      encore: this.props.show.encore,
      showWriteIn: false
    };
    this.onDragEnd = this.onDragEnd.bind(this);
    this.selectSetlistingSong = this.selectSetlistingSong.bind(this);
    this.writeInSetlistingSong = this.writeInSetlistingSong.bind(this);
  }

  onDragEnd = (result) => {
    // dropped outside the list
    if (!result.destination) {
      return;
    }

    if (result.source.index === this.state.encore) {
      // Just update the encore if that's what was dragged
      this.setState({ encore: result.destination.index });
    } else {
      let updatedEncore;

      // Remove encore draggable from index
      if (result.source.index >= this.state.encore ) {
        result.source.index -= 1;
      }
      if (result.destination.index >= this.state.encore ) {
        result.destination.index -= 1;
      }
      // If track was removed above encore, bump encore down
      if (result.source.index >= this.state.encore && result.destination.index <= this.state.encore ) {
        const updatedEncore = this.state.encore += 1;
      }

      const orderedSetlistings = reorder(
        this.state.setlistings,
        result.source.index,
        result.destination.index
      );

      // Positions seem to be "1" index (not zero indexed)
      orderedSetlistings.forEach((setlisting, i) => setlisting.position = (i + 1).toString());

      this.setState({
        setlistings: orderedSetlistings,
        encore: updatedEncore || this.state.encore
      });
    }
  }

  selectSetlistingSong(setlistingIndex, newSongId) {
    newSongId = Number(newSongId);
    const setlistings = this.state.setlistings;
    setlistings[setlistingIndex].song_id = newSongId;
    setlistings[setlistingIndex].song = this.props.allSongs.find(song => song.id === newSongId);
    this.setState({ setlistings })
  }

  writeInSetlistingSong(setlistingIndex, title) {
    const setlistings = this.state.setlistings;
    setlistings[setlistingIndex].song_id = null;
    setlistings[setlistingIndex].song = { title };
    this.setState({ setlistings })
  }

  render() {
    const draggables = Array.from(this.state.setlistings);
    draggables.splice(
      this.state.encore - 1,
      0,
      {
        id: 'encore',
        isEncore: true
      }
    )

    return <div>
      <div className="setlist__header">
        <div className="setlist__header__title">
          Setlist
        </div>
        <a className="setlist__header__action"
           onClick={this.props.hideSetListEditor}>
          Cancel
        </a>
      </div>

      <div className="setlist__tracks">
        <DragDropContext onDragEnd={this.onDragEnd}>
          <Droppable droppableId="setlist-editor">
            {(provided, snapshot) => (
              <ul ref={provided.innerRef}>
                {draggables.map((item, index) =>
                  <Draggable key={item.id}
                             draggableId={item.id}
                             index={index}>
                    {(provided, snapshot) => (
                      item.isEncore ? (
                        <div className="setlist__encore" ref={provided.innerRef} {...provided.draggableProps}>
                          Encore
                          <span className="setlist__encore__drag" {...provided.dragHandleProps}>drag</span>
                        </div>
                      ) : (
                        <SongEditor index={index}
                                    setlisting={item}
                                    allSongs={this.props.allSongs}
                                    draggableRef={provided.innerRef}
                                    draggableProps={provided.draggableProps}
                                    dragHandleProps={provided.dragHandleProps}
                                    selectSetlistingSong={this.selectSetlistingSong}
                                    writeInSetlistingSong={this.writeInSetlistingSong} />
                      )
                    )}
                  </Draggable>
                )}
                {provided.placeholder}
              </ul>
            )}
          </Droppable>
        </DragDropContext>

        <button className="button setlist__submit"
                type="submit"
                onClick={() => this.props.save(this.state.setlistings, this.state.encore)}>
          Save Setlist
        </button>
      </div>
    </div>
  }
}

export default SetlistEditor;
