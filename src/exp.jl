
const J_TABLE = Float64[2^(big(j-1)/1024) for j in 1:1024];
# const J_TABLE_ptr = pointer(J_TABLE)

@inline function gexp(x::F64)
    # k = 10
    # Range reduction coefficients:
    # log(2) inverted = 2^k/ln2 
    __dbInvLn2 = reinterpret(Float64, 0x40971547652b82fe)
    # right-shifter value = 3*2^52 
    __dbShifter = reinterpret(Float64, 0x4338000000000000)
    # log(2) high part = ln2/2^k(52-k-9 hibits) 
    __dbLn2hi = reinterpret(Float64, 0x3f462e42fec00000)
    # log(2) low part = ln2/2^k(52-k-9..104-k-9 lobits) 
    __dbLn2lo = reinterpret(Float64, 0x3d5d1cf79abc9e3b)
    # Polynomial coefficients (k=10, deg=3): */
    __dPC0 = reinterpret(Float64, 0x3ff0000000000000)
    __dPC1 = reinterpret(Float64, 0x3fe0000001ebfbe0)
    __dPC2 = reinterpret(Float64, 0x3fc5555555555556)
    # Other constants:
    # index mask = 2^k-1 
    __lIndexMask = 0x00000000000003ff
    # absolute value mask (SP) 
    # __iAbsMask = 0x7fffffff
    # __iDomainRange = 0x4086232a
    
    xint = reinterpret(UInt64, x)
    # xshift = xint >> 32
    dM = fma(x, __dbInvLn2, __dbShifter)
    # xshift32 = vconvert(SVec{W,UInt32}, xshift)
    # dN = SIMDPirates.evsub(dM, __dbShifter)
    dN = dM - __dbShifter
    # iAbsX = xshift32 & __iAbsMask
    
    dR = vfnmadd(dN, __dbLn2hi, x)
    dR = vfnmadd(dN, __dbLn2lo, dR)

    # @show dR
    expr = fma(fma(fma(__dPC2, dR, __dPC1), dR, __dPC0), dR, __dPC0)

    # iRangeMask = reinterpret(SVec{W,Int32}, iAbsX) > __iDomainRange

    dMi = reinterpret(UInt64, dM)
    # lIndex = SVec(gather(SIMDPirates.gep(pointer(J_TABLE), dMi & __lIndexMask), Val(false)))
    lIndex = vload(stridedpointer(J_TABLE), (dMi & __lIndexMask,))
    
    # @show lIndex
    jR = lIndex * expr

    # @show dN dM jR
    lM = (dMi & (~__lIndexMask)) << 42

    reti = lM + reinterpret(UInt64, jR)
    reinterpret(Float64, reti)
end

@inline function gexp(x::F32)
    # k = 0
    # log(2) inverted
    __sInvLn2 = reinterpret(Float32, 0x3fb8aa3b)

    # right shifter constant
    __sShifter = reinterpret(Float32, 0x4b400000)

    # log(2) high part 
    __sLn2hi = reinterpret(Float32, 0x3f317200)

    # log(2) low part
    __sLn2lo = reinterpret(Float32, 0x35bfbe8e)

    # bias
    __iBias = 0x0000007f

    # Polynomial coefficients:
    # Here we approximate 2^x on [-0.5, 0.5]
    __sPC0 = reinterpret(Float32, 0x3f800000)
    __sPC1 = reinterpret(Float32, 0x3f7ffffe)
    __sPC2 = reinterpret(Float32, 0x3effff34)
    __sPC3 = reinterpret(Float32, 0x3e2aacac)
    __sPC4 = reinterpret(Float32, 0x3d2b8392)
    __sPC5 = reinterpret(Float32, 0x3c07d9fe)

    # __iAbsMask 0x7fffffff
    # __iDomainRange 0x42aeac4f
    
    sM = fma(__sInvLn2, x, __sShifter)
    sN = sM - __sShifter
    b = __iBias + reinterpret(UInt32, sM)
    sR = vfnmadd(sN, __sLn2hi, x)
    twotosN = b << 0x0000017
    
    sR = vfnmadd(sN, __sLn2lo, sR)

    expr = fma(fma(fma(fma(fma(__sPC5, sR, __sPC4), sR, __sPC3), sR, __sPC2), sR, __sPC1), sR, __sPC0)

    expr * reinterpret(Float32, twotosN)
    
end

