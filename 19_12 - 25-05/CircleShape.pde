public class CircleShape extends Shape {
  public CircleShape(float x, float y) {
    super(x, y);
  }

  @Override
    protected void drawSpecificShape() {
    ellipseMode(CENTER);
    ellipse(0, 0, size, size);
  }

  @Override
    protected void drawSelectionOutline() {
    ellipse(0, 0, size, size);
  }

  @Override
    public boolean isMouseOverShape(float mx, float my) {
    return dist(mx, my, x, y) < size/2;
  }
}
