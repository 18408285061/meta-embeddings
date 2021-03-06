function [f,fi,paramsz] = create_linTrans(dim)

    if nargout==0
        test_this();
        return;
    end


    f = @f_this; 
    
    fi = @fi_this;
    
    paramsz = dim^2;
    
    function T = f_this(P,R)
        M = unpack(P);
        T = M*R;
    end
    
    
    function [R,logdetJ,back] = fi_this(P,T)
        M = unpack(P);
        
        [L,U] = lu(M);
        n = size(T,2);
        logdetJ = n*sum(log(diag(U).^2))/2;
        Delta = T;
        R = U\(L\Delta);
        back = @back_this;
    

        function [dP,dT] = back_this(dR,dlogdetJ)
            dM = (n*dlogdetJ)*(U\inv(L)).';
            dDelta = L.'\(U.'\dR);
            dM = dM - dDelta*R.';
            dP = dM(:);
            dT = dDelta;
        end
    
    end


    function P = unpack(P)
        P = reshape(P,dim,dim);
    end

end

function test_this()

    dim = 3;
    [f,fi,sz] = create_linTrans(dim);
    R = randn(dim,5);
    P = randn(sz,1);
    T = f(P,R);
    ff = @(P,T) fi(P,T);

    testBackprop_multi(ff,2,{P,T});
    
    
end

