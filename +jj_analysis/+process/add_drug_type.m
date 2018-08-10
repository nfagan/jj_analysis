function cont = add_drug_type(cont)

cont = cont.require_fields( 'drug' );

[I, C] = cont.get_indices( 'notes' );

for i = 1:numel(I)
  note = C{i, 1};
  
  is_sal = ~isempty( strfind(note, 'saline') );
  is_oxy = ~isempty( strfind(note, 'oxytocin') );
  is_ot = ~isempty( strfind(note, 'OT') );
  
  if ( is_sal )
    assert( ~is_oxy && ~is_ot, 'Identified saline, but also OT or oxy' );
    
    cont('drug', I{i}) = 'saline';
    
    continue;
  end
  
  if ( is_oxy || is_ot )
    cont('drug', I{i}) = 'oxytocin';
    
    continue;
  end
  
end

end