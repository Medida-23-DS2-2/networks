using Godot;
using System;

public class Grid : Resource
{
  [Export]
  public Vector2 size = new Vector2(16, 9);
  [Export]
  public Vector2 cellSize = new Vector2(64, 64);

  // Stores entities on the index of their root vector (top left) 
  GridEntity[] _entities;

  Vector2 calculateMapPosition(Vector2 cell)
  {
    return cell * cellSize + (cellSize / 2);
  }

  Vector2 calculateGridPosition(Vector2 mapPosition)
  {
    return (mapPosition / cellSize).Floor();
  }

  // Resolves to an array of grid entities that contains references to 
  public GridEntity[] getResolvedGridEntities()
  {
    GridEntity[] resolved = Array.Empty<GridEntity>();
    foreach (var entity in _entities)
    {
      int rootIndex = Array.FindIndex(_entities, e => e == entity);
      Vector2 rootVector = asVector(rootIndex);
      for (int deltaDimX = 0; deltaDimX < entity.dimension.x; deltaDimX++)
      {
        for (int deltaDimY = 0; deltaDimY < entity.dimension.y; deltaDimX++)
        {
          Vector2 currentGridPosition = new Vector2(rootVector.x + deltaDimX, rootVector.y + deltaDimY);
          resolved[asIndex(currentGridPosition)] = entity;
        }
      }

      // resolved[asIndex(entity.)]
    }
    return resolved;
  }

  void addGridEntity(GridEntity entity, Vector2 rootCell)
  {

  }

  /* 	bool isEmptyCell(Vector2 cell) {
      return (cell)
    } */

  bool isWithinBounds(Vector2 cell)
  {
    return (cell.x >= 0 && cell.x < size.x) && (cell.y >= 0 && cell.y < size.y);
  }

  int asIndex(Vector2 cell)
  {
    return (int)(cell.x + size.x * cell.y);
  }

  Vector2 asVector(int index)
  {
    return new Vector2(index % size.x, (float)Math.Floor(index / size.x));
  }

  //  // Called every frame. 'delta' is the elapsed time since the previous frame.
  //  public override void _Process(float delta)
  //  {
  //      
  //  }
}
