using Godot;
using System;
using System.Linq;

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
    return cell * this.cellSize + (this.cellSize / 2);
  }

  Vector2 calculateGridPosition(Vector2 mapPosition)
  {
    return (mapPosition / this.cellSize).Floor();
  }

  // Resolves to an array of grid indices that contain references to their respective contents
  public GridEntity[] getResolvedGridEntities()
  {
    GridEntity[] resolved = Array.Empty<GridEntity>();
    foreach (var entity in this._entities)
    {
      int rootIndex = Array.FindIndex(this._entities, e => e == entity);
      Vector2 rootCell = asVector(rootIndex);
      for (int deltaDimX = 0; deltaDimX < entity.dimension.x; deltaDimX++)
      {
        for (int deltaDimY = 0; deltaDimY < entity.dimension.y; deltaDimX++)
        {
          int dX = (int)rootCell.x + deltaDimX;
          int dY = (int)rootCell.y + deltaDimY;
          Vector2 currentGridPosition = new Vector2(dX, dY);

          if (!isWithinBounds(currentGridPosition))
          {
            throw new ArgumentOutOfRangeException($"Entity {entity.GetInstanceId()} is out of bounds for dimension (${dX}, ${dY})");
          }

          resolved[asIndex(currentGridPosition)] = entity;
        }
      }
    }
    return resolved;
  }

  void addGridEntity(GridEntity entity, Vector2 rootCell)
  {
    GridEntity[] resolvedGridEntities = getResolvedGridEntities();
    for (int deltaDimX = 0; deltaDimX < entity.dimension.x; deltaDimX++)
    {
      for (int deltaDimY = 0; deltaDimY < entity.dimension.y; deltaDimX++)
      {
        int dX = (int)rootCell.x + deltaDimX;
        int dY = (int)rootCell.y + deltaDimY;
        Vector2 currentGridPosition = new Vector2(dX, dY);

        if (!isWithinBounds(currentGridPosition))
        {
          throw new ArgumentOutOfRangeException($"Entity {entity.GetInstanceId()} is out of bounds for dimension (${dX}, ${dY})");
        }

        if (!isEmptyCell(currentGridPosition))
        {
          throw new ArgumentException($"Entity {entity.GetInstanceId()} is trying to reserve blocked tiles for dimension (${dX}, ${dY})");
        }
      }
    }

    this._entities[asIndex(rootCell)] = entity;
    GetLocalScene().AddChild(entity);
  }

  bool isEmptyCell(Vector2 cell)
  {
    return getResolvedGridEntities().ElementAtOrDefault(asIndex(cell)) == null;
  }

  bool isWithinBounds(Vector2 cell)
  {
    return (cell.x >= 0 && cell.x < size.x) && (cell.y >= 0 && cell.y < size.y);
  }

  int asIndex(Vector2 cell)
  {
    return (int)(cell.x + this.size.x * cell.y);
  }

  Vector2 asVector(int index)
  {
    return new Vector2(index % this.size.x, (float)Math.Floor(index / this.size.x));
  }

  //  // Called every frame. 'delta' is the elapsed time since the previous frame.
  //  public override void _Process(float delta)
  //  {
  //      
  //  }
}
