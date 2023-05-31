using Godot;
using System;

public class Grid : Resource
{
	[Export]
	public Vector2 size = new Vector2(16, 9);
	[Export]
	public Vector2 cellSize = new Vector2(64, 64);

	public Vector2 calculateMapPosition(Vector2 cell) {
		return cell * cellSize + (cellSize / 2);
	}

	public Vector2 calculateGridPosition(Vector2 mapPosition) {
		return (mapPosition / cellSize).Floor();
	}

	public bool isWithinBounds(Vector2 cell) {
		return (cell.x >= 0 && cell.x < size.x) && (cell.y >= 0 && cell.y < size.y);
	}

	public int asIndex(Vector2 cell) {
		return (int)(cell.x + size.x * cell.y);
	}

//  // Called every frame. 'delta' is the elapsed time since the previous frame.
//  public override void _Process(float delta)
//  {
//      
//  }
}
