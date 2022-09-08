CREATE Function [dbo].[fnStripInvalidCongDongCharacters](@Temp VarChar(1000))
Returns VarChar(1000)
AS
Begin

    Declare @KeepValues as varchar(50)
    Set @KeepValues = '%[A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z]%'
    While PatIndex(@KeepValues, @Temp) > 0
        Set @Temp = REPLACE(Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, ''), 'Ð', 'D')

    Return @Temp
End