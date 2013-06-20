function [DB] = integrate_DB_MAPs( DB1, DB2 )

	DB.U = integrate_U( DB1, DB2 );
	DB.T = integrate_T( DB1.T, DB2.T );
	DB.V = integrate_V( DB1.V, DB2.V );
	DB.VOL = integrate_VOL( DB1.VOL, DB2.VOL );

end


function [U] = integrate_U( U1, U2 )



end