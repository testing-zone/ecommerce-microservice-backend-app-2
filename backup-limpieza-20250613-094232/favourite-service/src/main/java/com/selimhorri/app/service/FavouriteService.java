package com.selimhorri.app.service;

import java.util.List;

import com.selimhorri.app.domain.id.FavouriteId;
import com.selimhorri.app.dto.FavouriteDto;

public interface FavouriteService {
	
	List<FavouriteDto> findAll();
	FavouriteDto findById(final FavouriteId favouriteId);
	FavouriteDto save(final FavouriteDto favouriteDto);
	FavouriteDto update(final FavouriteDto favouriteDto);
	void deleteById(final FavouriteId favouriteId);
	
}
