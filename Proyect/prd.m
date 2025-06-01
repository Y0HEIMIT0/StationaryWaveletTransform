function y=prd(Pro__Sig,Orig_Sig)
    % PRD: The Percent Root Mean Square Difference.
    % The Percent Root Difference (PRD) has been widely used in the literature
    % as the principal error criterion.   
    % Orig_Sig: Orig_Sig Signal
    % Pro_Sig: Processed Signal
    %   Author(s): S. BOUREZG, 02.16.2015  
    %   Reference: 
    %   1) R. Benzid, A. Messaoudi, A. Boussaad, � Constrained ECG compression 
    %      algorithm using the block-based discrete cosine transform�, 
    %      Digital Signal Processing 18, pp.56�64, 2008.
    if nargin == 0,
        error(generatemsgid('Nargchk'),'Not enough input arguments.');
    else
        if nargin == 1,
        error(generatemsgid('Nargchk'),'input arguments must be two.');
        end
        Pro__Sig=double(Pro__Sig);
        Orig_Sig=double(Orig_Sig);
     
        %Error
        Error=Pro__Sig - Orig_Sig;
        se=Error.*Error;
        sumse=sum(se);
        %PRD Calculation
        ma=Pro__Sig.*Orig_Sig;
        summa=sum(ma);
        y=100*sqrt(sumse/summa);
    end