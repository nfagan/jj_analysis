function rebuilt = fill_missing_per_block(obj, fs, C, with)

import jj_analysis.util.general.*;

dates = obj( 'date' );
rebuilt = Container();
for i = 1:numel( dates )
    one_day = obj.only( dates{i} );
    blocks = one_day( 'block' );
    for j = 1:numel(blocks)
        one_block = one_day.only( blocks{j} );
        one_block = fill_missing( one_block, fs, C, with );
        rebuilt = rebuilt.append( one_block );
    end
end



end