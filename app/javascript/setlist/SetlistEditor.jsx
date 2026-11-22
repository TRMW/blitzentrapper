import { useState } from "react";
import { DragDropContext, Droppable, Draggable } from "@hello-pangea/dnd";
import SongEditor from "./SongEditor";
import { buildDraggables, moveDraggable, selectSong, writeInSong } from "./setlistLogic";

// Drag-and-drop editor for a show's setlist and encore divider.
export default function SetlistEditor({ show, allSongs, onCancel, onSave }) {
  // Number every slot, including the blank ones the server adds, which
  // arrive without a position.
  const [ setlistings, setSetlistings ] = useState(() =>
    show.setlistings.map((setlisting, i) => ({ ...setlisting, position: String(i + 1) }))
  );
  const [ encore, setEncore ] = useState(show.encore);
  const [ saving, setSaving ] = useState(false);
  const [ error, setError ] = useState(null);

  function handleDragEnd({ source, destination }) {
    if (!destination) return; // dropped outside the list
    const moved = moveDraggable(setlistings, encore, source.index, destination.index);
    setSetlistings(moved.setlistings);
    setEncore(moved.encore);
  }

  function updateSetlisting(id, update) {
    setSetlistings((current) =>
      current.map((setlisting) => (setlisting.id === id ? update(setlisting) : setlisting))
    );
  }

  async function handleSave() {
    setSaving(true);
    setError(null);
    try {
      await onSave(setlistings, encore);
    } catch (e) {
      setError(`Couldn't save the setlist (${e.message}). Please try again.`);
      setSaving(false);
    }
  }

  return (
    <div>
      <div className="setlist__header">
        <div className="setlist__header__title">Setlist</div>
        <a className="setlist__header__action" onClick={onCancel}>Cancel</a>
      </div>

      <div className="setlist__tracks">
        <DragDropContext onDragEnd={handleDragEnd}>
          <Droppable droppableId="setlist-editor">
            {(provided) => (
              <ul ref={provided.innerRef} {...provided.droppableProps}>
                {buildDraggables(setlistings, encore).map((item, index) => (
                  <Draggable key={item.id} draggableId={String(item.id)} index={index}>
                    {(draggable) => item.isEncore ? (
                      <div
                        className="setlist__encore"
                        ref={draggable.innerRef}
                        {...draggable.draggableProps}
                      >
                        Encore
                        <span className="setlist__encore__drag" {...draggable.dragHandleProps}>
                          drag
                        </span>
                      </div>
                    ) : (
                      <SongEditor
                        setlisting={item}
                        allSongs={allSongs}
                        innerRef={draggable.innerRef}
                        draggableProps={draggable.draggableProps}
                        dragHandleProps={draggable.dragHandleProps}
                        onSelectSong={(songId) =>
                          updateSetlisting(item.id, (s) => selectSong(s, songId, allSongs))}
                        onWriteIn={(title) =>
                          updateSetlisting(item.id, (s) => writeInSong(s, title, allSongs))}
                      />
                    )}
                  </Draggable>
                ))}
                {provided.placeholder}
              </ul>
            )}
          </Droppable>
        </DragDropContext>

        {error && <p className="setlist__error">{error}</p>}
        <button
          className="button setlist__submit"
          type="submit"
          disabled={saving}
          onClick={handleSave}
        >
          {saving ? "Saving…" : "Save Setlist"}
        </button>
      </div>
    </div>
  );
}
