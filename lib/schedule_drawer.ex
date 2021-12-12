defmodule ScheduleDrawer do
  @moduledoc """
  Отрисовщик расписания.
  """

  import NotExistedImageLibrary

  @background 0xFFFFFF
  @font %Font{path: "font.tff"}
  @line_background 0x888888
  @line_height 2
  @padding 10

  @doc """
  Отрисовка расписания.
  """
  def draw(%Schedule{class_title, date, timebreaks, subjects, cabinets}) do
    start_draw()
    |> draw_title(class_title, date)
    |> draw_main(timebreaks, subjects, cabinets)
    |> combine_images
    |> add_padding
  end

  @doc """
  Список с изображениями, которые
  будут объединены в одно изображение.
  """
  defp start_draw, do: []

  @doc """
  Отрисовка заголовка расписания.
  """
  defp draw_title(image_parts, class_title, date) do
    image =
      format_title(class_title, date)
      |> render_text
      |> add_padding

    [image | image_parts]
  end

  @doc """
  Форматирование заголовка расписания.
  Имеет вид: "Класс . Дата . День недели"
  Пример: "11А . 8 дек 2021 . Среда"
  """
  defp format_title(class_title, date) do
    "#{class_title} #{date}"
  end

  @doc """
  Добавление отступа к изображению.
  """
  defp add_padding(image) do
    %Image{width, height} = image

    %Image{
      width: width + @padding * 2,
      height: height + @padding * 2,
      color: @background
    }
    |> draw(image, at: [x: @padding, y: @padding])
  end

  @doc """
  Отрисовка таблицы уроков.
  """
  defp draw_main(image_parts, timebreaks, subjects, cabinets) do
    image =
      Enum.zip(timebreaks, subjects, cabinets)
      |> Enum.map(&draw_row/3)
      |> add_lines
      |> combine_images

    [image | image_parts]
  end

  @doc """
  Отрисовка ряда таблицы уроков.
  """
  defp draw_row(timebreak, subject, cabinet) do
    format_row(timebreak, subject, cabinet)
    |> render_text
    |> add_padding
  end

  @doc """
  Форматирование ряда таблицы уроков.
  Имеет вид: "Время урока  Название урока  Номер кабинета"
  Пример: "8:00-8:40  Информатика  9"
  """
  defp format_row(timebreak, subject, cabinet) do
    "#{timebreak} #{subject} #{cabinet}"
  end

  @doc """
  Добавление линий между рядами таблицы уроков.
  """
  defp add_lines(rows) do
    line_width = Enum.max_by(rows, fn row -> row.width end)

    Enum.intersperse(rows, draw_line(line_width))
  end

  @doc """
  Отрисовка перегородки между рядами расписания.
  """
  defp draw_line(width) do
    %Image{width: width, height: @line_height, color: @line_background}
  end

  @doc """
  Соединение нескольких изображений в одно.
  """
  defp combine_images(images) do
    width = Enum.max_by(rows, fn row -> row.width end)

    height = Enum.reduce(images, 0, fn image, total -> total + image.height end)
    combined = %Image{width: width, height: height, color: @background}

    images
    |> Enum.reverse()
    |> Enum.zip(accumulate_heights(images))
    |> Enum.reduce(combined, fn {image, y}, acc -> draw(combined, image, at: [x: 0, y: y]) end)
  end

  @doc """
  Подсчёт суммарных высот изображений.
  Используется для последовательной вертикальной отрисовки
  нескольких изображений на другом изображении.
  """
  defp accumulate_heights(images) do
    accumulated_heights =
      images
      |> Enum.map(fn image -> image.height end)
      |> Enum.scan(fn height, total -> height + total end)
      |> Enum.drop(1)

    [0 | accumulated_heights]
  end
end
