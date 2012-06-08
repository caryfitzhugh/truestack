module ApplicationHelper
  def get_slope(array)
    xs = (0..array.length)
    lineFit = LineFit.new
    lineFit.setData(xs.to_a, array)
    tStatIntercept, tStatSlope = lineFit.tStatistics
    tStatSlope
  end
end
