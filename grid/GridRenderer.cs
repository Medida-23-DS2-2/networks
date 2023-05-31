using Godot;
using System;

public class GridRenderer : Node2D
{
  Grid grid = ResourceLoader.Load("res://grid/Grid.tres") as Grid;

  [Export]
  public Color lineColor;
  public override void _Draw()
  {
    drawGridLines();
  }

  public override void _Process(float delta)
  {
    // Update();
  }

  void drawGridLines()
  {
    int xMax = (int)(grid.cellSize.x * grid.size.x);
    int yMax = (int)(grid.cellSize.y * grid.size.y);

    // Draw Lines along X Axis
    for (int yCoord = 0; yCoord < grid.size.y; yCoord++)
    {
      Vector2 from = new Vector2(0, yCoord * grid.cellSize.y);
      Vector2 to = new Vector2(xMax, yCoord * grid.cellSize.y);
      DrawLine(from, to, lineColor);
    }

    // Draw Lines along Y Axis
    for (int xCoord = 0; xCoord < grid.size.x; xCoord++)
    {
      Vector2 from = new Vector2(xCoord * grid.cellSize.x, 0);
      Vector2 to = new Vector2(xCoord * grid.cellSize.x, yMax);
      DrawLine(from, to, lineColor);
    }


  }
}
