class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    sort = params[:sort] # Tells us which column to sort by
    
    if sort == 'title'
      @movies = Movie.order(title: :asc)
      @date_class = ''
      @title_class = 'hilite'
    elsif sort == 'release_date'
      @movies = Movie.order(release_date: :asc)
      @date_class = 'hilite'
      @title_class = ''
    else
      @movies = Movie.all
      @date_class = ''
      @title_class = ''
    end
  end

  def sort
    sort_by = params[:sort_by] # Tells us which column to sort by
    
    if sort_by == 'title'
      @movies = Movie.order(title: :asc)
    elsif sort_by == 'release_date'
      @movies = Movie.order(release_date: :asc)
    end
  end
  
  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
