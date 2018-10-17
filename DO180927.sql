
/**
 **��λ�������
 **
 **/

ALTER PROCEDURE [dbo].[ApproveContract_WP]
  @ContractID		NVARCHAR(36),
  @UserName			NVARCHAR(30),
  @InfoMsg			NVARCHAR(500) output
AS

	DECLARE @I				INT,
			@Month			INT,
			@Days			INT,
			@NaturalDays	INT,
			@Ratio			Decimal(15,10),
			@J				INT,
			@MAXJ			INT,
			@K				INT,
			@MAXK			INT
			
	DECLARE @RowPointer			NVARCHAR(36),
			@FeeStartDate		DateTime,
			@ContractEndDate	DateTime,
			@StartDate			DateTime,
			@EndDate			DateTime,
			@SRVDecimalPoint	INT,
			@SRVRoundType		NVARCHAR(10),
			@RMID				NVARCHAR(30),
			@WPNo				NVARCHAR(30),
			@SRVNo				NVARCHAR(30),
			@FeeAmount			DECIMAL(15,5),
			@WPQTY				INT,
			@WPRentalUnitPrice	DECIMAL(15,4),
			@CustNo				NVARCHAR(30),
			--����ʱ��
			@ReduceStartDate1	DateTime,
			@ReduceEndDate1		DateTime,	
			@ReduceStartDate2	DateTime,
			@ReduceEndDate2		DateTime,	
			@ReduceStartDate3	DateTime,
			@ReduceEndDate3		DateTime,	
			@ReduceStartDate4	DateTime,
			@ReduceEndDate4		DateTime,
				
			@OverElectricFeeSRVNo	NVARCHAR(30),	--������
			@WPOverElectricyPrice	DECIMAL(15,4),	--�����ѵ���
			@WPRentFeeSRVNo			NVARCHAR(30),	--��λ�����
			@WPFWFSRVNo				NVARCHAR(30),	--��λ����ѱ��
			@WPFWFPoint				INT,			--��λ����
			@WPFWFRoundType			NVARCHAR(10)	--ȡ����ʽ
			
	DECLARE @IncreaseStartDate1		NVARCHAR(10),		--������ʼʱ��1
			@IncreaseRate1			Decimal(15,4),		--������1
			@IncreaseStartDate2		NVARCHAR(10),		--������ʼʱ��2
			@IncreaseRate2			Decimal(15,4),		--������2
			@IncreaseStartDate3		NVARCHAR(10),		--������ʼʱ��3
			@IncreaseRate3			Decimal(15,4),		--������3
			@IncreaseStartDate4		NVARCHAR(10),		--������ʼʱ��4
			@IncreaseRate4			Decimal(15,4),		--������4
			
			@IncreaseDATE1			NVARCHAR(10),		
			@IncreaseDATE2			NVARCHAR(10),
			@IncreaseRate			Decimal(15,4),
			@IncreaseTims			INT,
			@IncreaseType			NVARCHAR(10),
			@IsContinue		BIT
			
	CREATE TABLE #TEMP_DATE
	(
		LINE INT IDENTITY(1,1),
		DATE1 NVARCHAR(10),
		DATE2 NVARCHAR(10),
		IncreaseTims INT,
		IncreaseRate Decimal(15,4)
	)

	BEGIN TRAN TR_OP 
	
		--��������ж�
		if not exists(select 1 from Op_Contract WHERE RowPointer=@ContractID)
		begin
			SET @InfoMsg = '��ǰ��ͬ��¼�����ڣ�'
			GOTO Error_Exit
		end
		if not exists(select 1 from Op_ContractWPRentalDetail where RefRP=@ContractID)
		begin
			SET @InfoMsg = '��ǰ��ͬ��ϸΪ�գ�'
			GOTO Error_Exit
		end
		if exists(select 1 from Op_ContractWPRentalDetail a left join Op_Contract b on a.RefRP=b.RowPointer 
					WHERE b.RowPointer<>@ContractID AND ContractStatus='2' AND B.ContractType='02' AND WPNo IN(
						SELECT WPNo FROM Op_ContractWPRentalDetail where RefRP=@ContractID))
		begin
			SET @InfoMsg = '��ǰ��ͬ��λ�ѱ�������ͬ�������޷�������'
			GOTO Error_Exit
		end
		
		if exists(select 1 from Op_ContractRMRentList WHERE RefRP=@ContractID AND FeeStatus='1')
		begin
			SET @InfoMsg = '��ǰ��ͬ�Ѿ����ɶ����������������ɣ�'
			GOTO Error_Exit
		end
		
		--��λ��
		SET @WPRentFeeSRVNo=(SELECT TOP 1 SRVNo FROM Sys_Setting WHERE SettingCode='WPRentFee')
		--��λ�����
  		SELECT  @WPFWFPoint=B.SRVDecimalPoint,
				@WPFWFRoundType=B.SRVRoundType,
				@WPFWFSRVNo=B.SRVNo
		FROM Mstr_Service B WHERE B.SRVNo=(SELECT TOP 1 SRVNo FROM Sys_Setting WHERE SettingCode='WPFWF')
		
		Delete from Op_ContractRMRentList WHERE RefRP=@ContractID	
		
		SET @I = 1
		SELECT	@Month = DATEDIFF(MONTH,FeeStartDate,ContractEndDate),--��ͬʱ��
				@FeeStartDate=FeeStartDate,
				@ContractEndDate=ContractEndDate,
				@CustNo = ContractCustNo,
				--����
				@IncreaseType=IncreaseType,
				@IncreaseStartDate1 = CONVERT(NVARCHAR(10),IncreaseStartDate1,121),	
				@IncreaseRate1 = IncreaseRate1,										
				@IncreaseStartDate2 = CONVERT(NVARCHAR(10),IncreaseStartDate2,121),
				@IncreaseRate2 = IncreaseRate2,
				@IncreaseStartDate3 = CONVERT(NVARCHAR(10),IncreaseStartDate3,121),
				@IncreaseRate3 = IncreaseRate3,
				@IncreaseStartDate4 = CONVERT(NVARCHAR(10),IncreaseStartDate4,121),
				@IncreaseRate4 = IncreaseRate4,
				--����
				@ReduceStartDate1=ReduceStartDate1,	--��������
				@ReduceEndDate1=ReduceEndDate1,
				@ReduceStartDate2=ReduceStartDate2,	--��������
				@ReduceEndDate2=ReduceEndDate2,
				@ReduceStartDate3=ReduceStartDate3,	--��������
				@ReduceEndDate3=ReduceEndDate3,
				@ReduceStartDate4=ReduceStartDate4,	--��������
				@ReduceEndDate4=ReduceEndDate4
				
				
		FROM Op_Contract
		WHERE RowPointer=@ContractID
		
		SET @Month+=1;
		WHILE(@I <= @Month)
		BEGIN					
			IF EXISTS(SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID=OBJECT_ID('TEMPDB..#TEMP1'))
				DROP TABLE #TEMP1
			
			SELECT IDENTITY(INT,1,1) AS LINE,* INTO #TEMP1 FROM Op_ContractWPRentalDetail WHERE RefRP=@ContractID
			SET @J=1
			SET @MAXJ=ISNULL((SELECT MAX(LINE) FROM #TEMP1),0)
			
			----------------------��λ���--------------------------
			WHILE(@J <= @MAXJ)
			BEGIN
				SET @IsContinue = 0	
				IF(@I = 1)
				BEGIN
					set @StartDate=@FeeStartDate
					set @EndDate=DATEADD(DAY,-1,DATEADD(MONTH,1,@FeeStartDate))
					SET @Days = DATEDIFF(DAY,@StartDate,@EndDate)+1
					SET @NaturalDays = DAY(DATEADD(DAY,-DAY(@StartDate),DATEADD(MONTH,1,@StartDate)))	
				END
				ELSE IF(@I = @Month) --���һ��
				BEGIN
					--1.�����ɵڶ���
					--����1��ֻ��һ���£�����2����ͬ�������� <= ��ͬ��ʼ���� + һ����
					IF (DATEDIFF(MONTH,@FeeStartDate,@ContractEndDate) <= 1 AND @ContractEndDate <= DATEADD(DAY,-1,DATEADD(MONTH,1,@FeeStartDate)) ) 
						SET @IsContinue = 1
					--2.ʣ�������������һ�£�����ֹһ������
					IF (DATEDIFF(MONTH,@FeeStartDate,@ContractEndDate) <= 1 AND @IsContinue = 0)
						SET @StartDate = DATEADD(MONTH,1,@FeeStartDate)
					ELSE
						SET @StartDate=DATEADD(DAY,-DAY(@ContractEndDate)+1,@ContractEndDate)
						
					set @EndDate=@ContractEndDate
					SET @Days = DATEDIFF(DAY,@StartDate,@EndDate)+1
					SET @NaturalDays = DAY(DATEADD(DAY,-DAY(DATEADD(MONTH,1,@EndDate)),DATEADD(MONTH,1,@EndDate)))	
				END
				ELSE IF(@I = 2)
				BEGIN
					set @StartDate=DATEADD(MONTH,1,@FeeStartDate)
					set @EndDate=DATEADD(DAY,-DAY(@FeeStartDate),DATEADD(MONTH,2,@FeeStartDate))
					SET @Days = DATEDIFF(DAY,@StartDate,@EndDate)+1
					SET @NaturalDays = DAY(@EndDate)					
				END
				ELSE
				BEGIN
					set @StartDate=DATEADD(DAY,-DAY(DATEADD(MONTH,@I-1,@FeeStartDate))+1,DATEADD(MONTH,@I-1,@FeeStartDate))
					set @EndDate=DATEADD(DAY,-DAY(DATEADD(MONTH,@I,@FeeStartDate)),DATEADD(MONTH,@I,@FeeStartDate))
					SET @Days = DATEDIFF(DAY,@StartDate,@EndDate)+1
					SET @NaturalDays = DAY(@EndDate)
				END
				
				IF(@Days>0 AND @IsContinue = 0)
				BEGIN				
			
					--��׼λ�� ȡ����ʽ
					SELECT @SRVDecimalPoint=B.SRVDecimalPoint,
							@SRVRoundType=B.SRVRoundType,
							@RMID=A.RMID,
							@WPNo=A.WPNo,
							@SRVNo=A.SRVNo,
							@WPQTY=A.WPQTY,
							@WPRentalUnitPrice=A.WPRentalUnitPrice,
							@RowPointer=RowPointer
					FROM #TEMP1 A 
						LEFT JOIN Mstr_Service B ON A.SRVNo=B.SRVNo 
					WHERE LINE=@J
					
					IF(@SRVNo = @WPRentFeeSRVNo or @SRVNo = @WPFWFSRVNo)
					BEGIN
						set @Ratio=0
						SET @FeeAmount = 0
						-------------���ǵ���������-------------
						TRUNCATE TABLE #TEMP_DATE
						IF(Year(@IncreaseStartDate1)>1901 or Year(@IncreaseStartDate2)>1901 or Year(@IncreaseStartDate3)>1901 or Year(@IncreaseStartDate4)>1901)				
						BEGIN						
							INSERT INTO #TEMP_DATE(DATE1,DATE2,IncreaseTims)
							SELECT * FROM DBO.TF_GetCuttingDate(CONVERT(NVARCHAR(10),@StartDate,121),CONVERT(NVARCHAR(10),@EndDate,121),
											@IncreaseStartDate1,@IncreaseStartDate2,@IncreaseStartDate3,@IncreaseStartDate4)
											
							UPDATE #TEMP_DATE SET IncreaseRate = 0 where IncreaseTims=0
							UPDATE #TEMP_DATE SET IncreaseRate = @IncreaseRate1 where IncreaseTims=1
							UPDATE #TEMP_DATE SET IncreaseRate = @IncreaseRate2 where IncreaseTims=2
							UPDATE #TEMP_DATE SET IncreaseRate = @IncreaseRate3 where IncreaseTims=3
							UPDATE #TEMP_DATE SET IncreaseRate = @IncreaseRate4 where IncreaseTims=4
								
							SET @K = 1
							SET @MAXK = ISNULL((SELECT MAX(LINE) FROM #TEMP_DATE),0)
							
							WHILE(@K<=@MAXK)
							BEGIN
								SELECT @IncreaseDATE1=DATE1,@IncreaseDATE2=DATE2,@IncreaseRate=IncreaseRate,@IncreaseTims=IncreaseTims FROM #TEMP_DATE WHERE LINE=@K						
								SET @Days = DBO.TF_GetDateOverlapDays(
									CONVERT(NVARCHAR(10),@ReduceStartDate1,121),
									CONVERT(NVARCHAR(10),@ReduceEndDate1,121),
									CONVERT(NVARCHAR(10),@ReduceStartDate2,121),
									CONVERT(NVARCHAR(10),@ReduceEndDate2,121),
									CONVERT(NVARCHAR(10),@ReduceStartDate3,121),
									CONVERT(NVARCHAR(10),@ReduceEndDate3,121),
									CONVERT(NVARCHAR(10),@ReduceStartDate4,121),
									CONVERT(NVARCHAR(10),@ReduceEndDate4,121),
									@IncreaseDATE1,@IncreaseDATE2
									)
								SET @Days = DATEDIFF(DAY,@IncreaseDATE1,@IncreaseDATE2) - @Days + 1		
															
								SET @Ratio = round(convert(decimal(15,4),@Days)/convert(decimal(15,4),@NaturalDays),10)
								--������
								IF(@IncreaseType = '1')
								BEGIN
									IF(@IncreaseTims = 1)
										SET @FeeAmount = @FeeAmount + @WPQTY*@WPRentalUnitPrice*@Ratio*(1+@IncreaseRate*0.01)
									ELSE IF(@IncreaseTims = 2)
										SET @FeeAmount = @FeeAmount + @WPQTY*@WPRentalUnitPrice*@Ratio*(1+@IncreaseRate*0.01)*(1+@IncreaseRate1*0.01)
									ELSE IF(@IncreaseTims = 3)
										SET @FeeAmount = @FeeAmount + @WPQTY*@WPRentalUnitPrice*@Ratio*(1+@IncreaseRate*0.01)*(1+@IncreaseRate1*0.01)*(1+@IncreaseRate2*0.01)
									ELSE IF(@IncreaseTims = 4)
										SET @FeeAmount = @FeeAmount + @WPQTY*@WPRentalUnitPrice*@Ratio*(1+@IncreaseRate*0.01)*(1+@IncreaseRate1*0.01)*(1+@IncreaseRate2*0.01)*(1+@IncreaseRate3*0.01)
									ELSE							
										SET @FeeAmount = @FeeAmount + @WPQTY*@WPRentalUnitPrice*@Ratio
								END
								--�̶����
								ELSE
								BEGIN
									IF(@IncreaseTims = 1)
										SET @FeeAmount = @FeeAmount + (@WPQTY*@WPRentalUnitPrice+@IncreaseRate)*@Ratio
									ELSE IF(@IncreaseTims = 2)
										SET @FeeAmount = @FeeAmount + (@WPQTY*@WPRentalUnitPrice+@IncreaseRate+@IncreaseRate1)*@Ratio
									ELSE IF(@IncreaseTims = 3)
										SET @FeeAmount = @FeeAmount + (@WPQTY*@WPRentalUnitPrice+@IncreaseRate+@IncreaseRate1+@IncreaseRate2)*@Ratio
									ELSE IF(@IncreaseTims = 4)
										SET @FeeAmount = @FeeAmount + (@WPQTY*@WPRentalUnitPrice+@IncreaseRate+@IncreaseRate1+@IncreaseRate2+@IncreaseRate3)*@Ratio
									ELSE							
										SET @FeeAmount = @FeeAmount + @WPQTY*@WPRentalUnitPrice*@Ratio
								END
								
								SET @K = @K + 1
							END
						END
						--û�е���
						ELSE
						BEGIN
							SET @Days = DBO.TF_GetDateOverlapDays(
								CONVERT(NVARCHAR(10),@ReduceStartDate1,121),
								CONVERT(NVARCHAR(10),@ReduceEndDate1,121),
								CONVERT(NVARCHAR(10),@ReduceStartDate2,121),
								CONVERT(NVARCHAR(10),@ReduceEndDate2,121),
								CONVERT(NVARCHAR(10),@ReduceStartDate3,121),
								CONVERT(NVARCHAR(10),@ReduceEndDate3,121),
								CONVERT(NVARCHAR(10),@ReduceStartDate4,121),
								CONVERT(NVARCHAR(10),@ReduceEndDate4,121),
								CONVERT(NVARCHAR(10),@StartDate,121),
								CONVERT(NVARCHAR(10),@EndDate,121)
								)
							SET @Days = DATEDIFF(DAY,@StartDate,@EndDate) - @Days + 1
							
							SET @Ratio = round(convert(decimal(15,4),@Days)/convert(decimal(15,4),@NaturalDays),10)
							SET @FeeAmount = @FeeAmount + @WPQTY*@WPRentalUnitPrice*@Ratio
						END
						-------------------------------------	
					
						IF(@SRVRoundType = 'ceiling')
						BEGIN
							INSERT INTO Op_ContractRMRentList(RowPointer,RefRP,RMID,WPNo,SRVNo,FeeStartDate,FeeEndDate,
								FeeQty,FeeUnitPrice,FeeAmount,FeeStatus,Creator,CreateDate,RefNo)
							SELECT NEWID(),@ContractID,@RMID,@WPNo,@SRVNo,@StartDate,@EndDate,
								@WPQTY,@WPRentalUnitPrice,Ceiling(@FeeAmount),
								'0',@UserName,GETDATE(),@RowPointer
							IF @@ERROR != 0 GOTO Error_Exit
						END
						ELSE IF(@SRVRoundType = 'floor')
						BEGIN
							INSERT INTO Op_ContractRMRentList(RowPointer,RefRP,RMID,WPNo,SRVNo,FeeStartDate,FeeEndDate,
								FeeQty,FeeUnitPrice,FeeAmount,FeeStatus,Creator,CreateDate,RefNo)
							SELECT NEWID(),@ContractID,@RMID,@WPNo,@SRVNo,@StartDate,@EndDate,
								@WPQTY,@WPRentalUnitPrice,floor(@FeeAmount),
								'0',@UserName,GETDATE(),@RowPointer
							IF @@ERROR != 0 GOTO Error_Exit
						END
						ELSE
						BEGIN
							INSERT INTO Op_ContractRMRentList(RowPointer,RefRP,RMID,WPNo,SRVNo,FeeStartDate,FeeEndDate,
								FeeQty,FeeUnitPrice,FeeAmount,FeeStatus,Creator,CreateDate,RefNo)
							SELECT NEWID(),@ContractID,@RMID,@WPNo,@SRVNo,@StartDate,@EndDate,
								@WPQTY,@WPRentalUnitPrice,Round(@FeeAmount,@SRVDecimalPoint),
								'0',@UserName,GETDATE(),@RowPointer
							IF @@ERROR != 0 GOTO Error_Exit
						END
					END
					
					--ELSE IF(@SRVNo = @WPFWFSRVNo) -- �����
					--BEGIN
					--	SELECT @WPQTY=M.WPSeat FROM Op_ContractPropertyFee C LEFT JOIN Mstr_WorkPlace M ON C.WPNo=M.WPNo WHERE C.RefRP=@ContractID AND C.SRVNo=@WPFWFSRVNo
					--	SET @Ratio = round(convert(decimal(15,4),@Days)/convert(decimal(15,4),@NaturalDays),10)
					--	SET @FeeAmount =@WPQTY*@WPRentalUnitPrice*@Ratio
												
					--	IF(@WPFWFRoundType = 'ceiling')
					--	BEGIN
					--		INSERT INTO Op_ContractRMRentList(RowPointer,RefRP,RMID,WPNo,SRVNo,FeeStartDate,FeeEndDate,
					--			FeeQty,FeeUnitPrice,FeeAmount,FeeStatus,Creator,CreateDate,RefNo)
					--		SELECT NEWID(),@ContractID,@RMID,@WPNo,@SRVNo,@StartDate,@EndDate,
					--			1,@WPRentalUnitPrice,Ceiling(@FeeAmount),'0',@UserName,GETDATE(),@RowPointer
					--		IF @@ERROR != 0 GOTO Error_Exit
					--	END
					--	ELSE IF(@WPFWFRoundType = 'floor')
					--	BEGIN
					--		INSERT INTO Op_ContractRMRentList(RowPointer,RefRP,RMID,WPNo,SRVNo,FeeStartDate,FeeEndDate,
					--			FeeQty,FeeUnitPrice,FeeAmount,FeeStatus,Creator,CreateDate,RefNo)
					--		SELECT NEWID(),@ContractID,@RMID,@WPNo,@SRVNo,@StartDate,@EndDate,
					--			1,@WPRentalUnitPrice,floor(@FeeAmount),'0',@UserName,GETDATE(),@RowPointer
					--		IF @@ERROR != 0 GOTO Error_Exit
					--	END
					--	ELSE
					--	BEGIN
					--		INSERT INTO Op_ContractRMRentList(RowPointer,RefRP,RMID,WPNo,SRVNo,FeeStartDate,FeeEndDate,
					--			FeeQty,FeeUnitPrice,FeeAmount,FeeStatus,Creator,CreateDate,RefNo)
					--		SELECT NEWID(),@ContractID,@RMID,@WPNo,@SRVNo,@StartDate,@EndDate,
					--			1,@WPRentalUnitPrice,Round(@FeeAmount,@WPFWFPoint),'0',@UserName,GETDATE(),@RowPointer
					--		IF @@ERROR != 0 GOTO Error_Exit
					--	END
					--END		
				
				END
				
				SET @J = @J + 1
			END
			----------------------��λ���--------------------------
			SET @I = @I + 1
		END
		
		
		--�޸Ĺ�λ����
		UPDATE Mstr_WorkPlace
		SET WPStatus='use'
		WHERE WPNo in (select WPNo from Op_ContractWPRentalDetail where RefRP=@ContractID)
		IF @@ERROR != 0 GOTO Error_Exit
		
		--�޸Ŀͻ�״̬
		UPDATE Mstr_Customer 
		SET CustStatus = '1'
        WHERE CustNo=@CustNo
		IF @@ERROR != 0 GOTO Error_Exit
        
		--�޸ĺ�ͬ״̬
		UPDATE Op_Contract 
		SET ContractStatus = '2', ContractAuditor = @UserName, ContractAuditDate = GETDATE()
        WHERE RowPointer=@ContractID
		IF @@ERROR != 0 GOTO Error_Exit
        

	COMMIT TRAN TR_OP
	SET @InfoMsg = ''
	RETURN 1  

Error_Exit:
BEGIN	
    ROLLBACK TRAN TR_OP
    if(@InfoMsg='') SET @InfoMsg = '���ݴ����쳣��'
	RETURN -1
END



GO





/**
 **��λ��ҵ���
 **
 **/

ALTER PROCEDURE [dbo].[ApproveContract_WPPT]
  @ContractID		NVARCHAR(36),
  @UserName			NVARCHAR(30),
  @InfoMsg			NVARCHAR(500) output
AS

	DECLARE @I				INT,
			@Month			INT,
			@Days			INT,
			@NaturalDays	INT,
			@Ratio			Decimal(15,10),
			@J				INT,
			@MAXJ			INT,
			@K				INT,
			@MAXK			INT
			
	DECLARE @RowPointer			NVARCHAR(36),
			@FeeStartDate		DateTime,
			@ContractEndDate	DateTime,
			@StartDate			DateTime,
			@EndDate			DateTime,
			@SRVDecimalPoint	INT,
			@SRVRoundType		NVARCHAR(10),
			@RMID				NVARCHAR(30),
			@WPNo				NVARCHAR(30),
			@SRVNo				NVARCHAR(30),
			@FeeAmount			DECIMAL(15,5),
			@WPQTY				INT,
			@WPRentalUnitPrice	DECIMAL(15,4),
			@CustNo				NVARCHAR(30),
			@IsContinue		BIT,
			@UnitPrice			DECIMAL(15,6)
			
	DECLARE	@OverElectricFeeSRVNo	NVARCHAR(30),	--�����ѱ��
			@WPOverElectricyPrice	DECIMAL(15,4)	--�����ѵ���
			
			
	CREATE TABLE #TEMP_DATE
	(
		LINE INT IDENTITY(1,1),
		DATE1 NVARCHAR(10),
		DATE2 NVARCHAR(10),
		IncreaseTims INT,
		IncreaseRate Decimal(15,4)
	)

	BEGIN TRAN TR_OP 
	
		--��������ж�
		if not exists(select 1 from Op_Contract WHERE RowPointer=@ContractID)
		begin
			SET @InfoMsg = '��ǰ��ͬ��¼�����ڣ�'
			GOTO Error_Exit
		end
		if not exists(select 1 from Op_ContractPropertyFee where RefRP=@ContractID)
		begin
			SET @InfoMsg = '��ǰ��ͬ��ϸΪ�գ�'
			GOTO Error_Exit
		end
		if exists(select 1 from Op_ContractPropertyFee a left join Op_Contract b on a.RefRP=b.RowPointer 
					WHERE b.RowPointer<>@ContractID AND ContractStatus='2' AND B.ContractType='05' AND WPNo IN(
						SELECT WPNo FROM Op_ContractPropertyFee where RefRP=@ContractID) AND SRVNo IN(
						SELECT SRVNo FROM Op_ContractPropertyFee WHERE RefRP=@ContractID))
		begin
			SET @InfoMsg = '��ǰ��ͬ��λĳЩ��Ŀ�ص����޷�������'
			GOTO Error_Exit
		end
		
		if exists(select 1 from Op_ContractRMRentList WHERE RefRP=@ContractID AND FeeStatus='1')
		begin
			SET @InfoMsg = '��ǰ��ͬ�Ѿ����ɶ����������������ɣ�'
			GOTO Error_Exit
		end
		
		
		--�����ѱ���
		SET @OverElectricFeeSRVNo=(SELECT TOP 1 SRVNo FROM Sys_Setting WHERE SettingCode='OverElectricFee')
		
		Delete from Op_ContractRMRentList WHERE RefRP=@ContractID	
		
		SET @I = 1
		--ʱ�����
		SELECT	@Month = DATEDIFF(MONTH,FeeStartDate,ContractEndDate),
				@FeeStartDate=FeeStartDate,
				@ContractEndDate=ContractEndDate,
				@CustNo = ContractCustNo
		FROM Op_Contract WHERE RowPointer=@ContractID
		set @Month+=1;
		WHILE(@I <= @Month)
		BEGIN		
			IF EXISTS(SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID=OBJECT_ID('TEMPDB..#TEMP7'))
				DROP TABLE #TEMP7
			
			SELECT IDENTITY(INT,1,1) AS LINE,* INTO #TEMP7 FROM Op_ContractPropertyFee WHERE RefRP=@ContractID
			SET @J=1
			SET @MAXJ=ISNULL((SELECT MAX(LINE) FROM #TEMP7),0)
					
			
			------------------------������--------------------------	
			SET @J=1
			WHILE(@J <= @MAXJ)
			BEGIN
				IF(@I = 1)
				BEGIN
					set @StartDate=@FeeStartDate
					set @EndDate=DATEADD(DAY,-DAY(@FeeStartDate),DATEADD(MONTH,1,@FeeStartDate))
					SET @Days = DATEDIFF(DAY,@StartDate,@EndDate)+1
					SET @NaturalDays = DAY(@EndDate)	
				END
				ELSE IF(@I = @Month) --���һ��
				BEGIN
					set @StartDate=DATEADD(DAY,-DAY(@ContractEndDate)+1,@ContractEndDate)
					set @EndDate=@ContractEndDate
					SET @Days = DATEDIFF(DAY,@StartDate,@EndDate)+1
					SET @NaturalDays = DAY(DATEADD(DAY,-DAY(@EndDate),DATEADD(MONTH,1,@EndDate)))	
				END
				ELSE
				BEGIN
					set @StartDate=DATEADD(DAY,-DAY(@FeeStartDate)+1,DATEADD(MONTH,@I-1,@FeeStartDate))
					set @EndDate=DATEADD(DAY,-DAY(@FeeStartDate),DATEADD(MONTH,@I,@FeeStartDate))
					SET @Days = DATEDIFF(DAY,@StartDate,@EndDate)+1
					SET @NaturalDays = DAY(@EndDate)
				END
				
				IF(@Days>0 AND DAY(@StartDate)<=15)
				BEGIN
					
					SELECT  @RMID=A.RMID,
							@WPNo=A.WPNo,
							@SRVNo=A.SRVNo,
							@RowPointer=RowPointer
					FROM #TEMP7 A 
					WHERE LINE=@J
					IF(@SRVNo = @OverElectricFeeSRVNo)
					BEGIN
					INSERT INTO Op_ContractRMRentList(RowPointer,RefRP,RMID,WPNo,SRVNo,FeeStartDate,FeeEndDate,
						FeeQty,FeeUnitPrice,FeeAmount,FeeStatus,Creator,CreateDate,RefNo)
					SELECT NEWID(),@ContractID,@RMID,@WPNo,@OverElectricFeeSRVNo,@StartDate,@EndDate,
						0,@WPOverElectricyPrice,0,'0',@UserName,GETDATE(),@RowPointer
					END
					IF @@ERROR != 0 GOTO Error_Exit
				END
		
				SET @J = @J + 1
			END
			
			----------------------������--------------------------
			
			
			SET @I = @I + 1
		END
		
		
		--�޸Ĺ�λ����
		UPDATE Mstr_WorkPlace
		SET WPStatus='use'
		WHERE WPNo in (select WPNo from Op_ContractWPRentalDetail where RefRP=@ContractID)
		IF @@ERROR != 0 GOTO Error_Exit
		
		--�޸Ŀͻ�״̬
		UPDATE Mstr_Customer 
		SET CustStatus = '1'
        WHERE CustNo=@CustNo
		IF @@ERROR != 0 GOTO Error_Exit
        
		--�޸ĺ�ͬ״̬
		UPDATE Op_Contract 
		SET ContractStatus = '2', ContractAuditor = @UserName, ContractAuditDate = GETDATE()
        WHERE RowPointer=@ContractID
		IF @@ERROR != 0 GOTO Error_Exit
        

	COMMIT TRAN TR_OP
	SET @InfoMsg = ''
	RETURN 1  

Error_Exit:
BEGIN	
    ROLLBACK TRAN TR_OP
    if(@InfoMsg='') SET @InfoMsg = '���ݴ����쳣��'
	RETURN -1
END


GO




ALTER PROCEDURE [dbo].[GenOrderFromContract]
  @TableName		NVARCHAR(30),
  @UserName			NVARCHAR(30),
  @InfoMsg			NVARCHAR(500) output
AS

	DECLARE @DateNow	DateTime,
			@K			INT,
			@MAXK		INT,
			@I			INT,
			@MAXI		INT,
			@J			INT,
			@MAXJ		INT
	
	DECLARE @ContractID				NVARCHAR(36),
			@ContractType			NVARCHAR(30),
			@FeeMonth				NVARCHAR(7),
			@CustNo					NVARCHAR(30),
			@SPNo					NVARCHAR(30),
			@OrderID				NVARCHAR(36),
			@OrderNo				NVARCHAR(30),
			@NewNo					NVARCHAR(30),
			@OrderDate				DateTime,
			@DaysofMonth			INT,
			@FeeStartDate			DateTime,
			@NaturalDays			INT
	
	DECLARE @RentRP					NVARCHAR(36),
			@RentRMID				NVARCHAR(30),
			@RentWPNo				NVARCHAR(30),
			@RentSRVNo				NVARCHAR(30)
	
	DECLARE @RMRentFeeSRVNo			NVARCHAR(30),	--�����
			@RMRentFeeSRVNo_DL		NVARCHAR(30),	--�����-����
			@WPRentFeeSRVNo			NVARCHAR(30),	--��λ��
			@WPSFSRVNo				NVARCHAR(30),	--��λ�����
			@BBRentFeeSRVNo			NVARCHAR(30),	--���λ���
			@WaterFeeSRVNo			NVARCHAR(30),	--ˮ��
			@ElectricFeeSRVNo		NVARCHAR(30),	--���
			@AirConditionFeeSRVNo	NVARCHAR(30),	--�յ���
			@PropertyFeeSRVNo		NVARCHAR(30),	--�����
			@ServiceChargeSRVNo		NVARCHAR(30),	--�̶������
			@OverElectricFeeSRVNo	NVARCHAR(30),	--������
			@SharedWaterFeeSRVNo	NVARCHAR(30),	--��̯ˮ��
			@SharedElectricFeeSRVNo	NVARCHAR(30),	--��̯���
			
			@WPElectricyLimit		DECIMAL(15,4),	--��λ�������
			@WPOverElectricyPrice	DECIMAL(15,4),	--��λ�������� --- ��Ϊȡ����
			@WPQTY					INT,			--��λ��
			@TotalWPQTY				INT,			--���ù�λ����
			@Multiples				INT				--����
			
	DECLARE @WaterFeeDecimalPoint			INT,
			@WaterFeeRoundType				NVARCHAR(10),
			@ElectricFeeDecimalPoint		INT,
			@ElectricFeeRoundType			NVARCHAR(10),
			@OverElectricFeeDecimalPoint	INT,
			@OverElectricFeeRoundType		NVARCHAR(10),
			@SharedWaterDecimalPoint		INT,
			@SharedWaterRoundType			NVARCHAR(10),
			@SharedWaterFee					DECIMAL(15,4),	--��̯ˮ�ѣ����ۣ�
			@SharedElectricFeeDecimalPoint	INT,
			@SharedElectricFeeRoundType		NVARCHAR(10),
			@SharedElectricFee				DECIMAL(15,4),	--��̯��ѣ����ۣ�
			@WaterFee						DECIMAL(15,4),	--ˮ�ѣ����ۣ�
			@ElectricFee					DECIMAL(15,4)	--��ѣ����ۣ�
			--@OverElectricFee				DECIMAL(15,4)	--�����ѣ����ۣ�
			
	SELECT  @WaterFeeDecimalPoint=B.SRVDecimalPoint,
			@WaterFeeRoundType=B.SRVRoundType,
			@WaterFeeSRVNo=B.SRVNo
	FROM Mstr_Service B
	WHERE B.SRVNo=(SELECT TOP 1 SRVNo FROM Sys_Setting WHERE SettingCode='WaterFee')
	
	SELECT  @ElectricFeeDecimalPoint=B.SRVDecimalPoint,
			@ElectricFeeRoundType=B.SRVRoundType,
			@ElectricFeeSRVNo=B.SRVNo
	FROM Mstr_Service B
	WHERE B.SRVNo=(SELECT TOP 1 SRVNo FROM Sys_Setting WHERE SettingCode='ElectricFee')
	
	SELECT  @OverElectricFeeDecimalPoint=B.SRVDecimalPoint,
			@OverElectricFeeRoundType=B.SRVRoundType,
			@OverElectricFeeSRVNo=B.SRVNo
	FROM Mstr_Service B
	WHERE B.SRVNo=(SELECT TOP 1 SRVNo FROM Sys_Setting WHERE SettingCode='OverElectricFee')
			
	SELECT  @SharedWaterDecimalPoint=B.SRVDecimalPoint,
			@SharedWaterRoundType=B.SRVRoundType,
			@SharedWaterFeeSRVNo=B.SRVNo
	FROM Mstr_Service B
	WHERE B.SRVNo=(SELECT TOP 1 SRVNo FROM Sys_Setting WHERE SettingCode='SharedWaterFee')
	
	SELECT  @SharedElectricFeeDecimalPoint=B.SRVDecimalPoint,
			@SharedElectricFeeRoundType=B.SRVRoundType,
			@SharedElectricFeeSRVNo=B.SRVNo
	FROM Mstr_Service B
	WHERE B.SRVNo=(SELECT TOP 1 SRVNo FROM Sys_Setting WHERE SettingCode='SharedElectricFee')
	
	SET @WPSFSRVNo = ISNULL((SELECT TOP 1 SRVNo FROM Sys_Setting WHERE SettingCode='WPFWF'),'')
	SET @RMRentFeeSRVNo = ISNULL((SELECT TOP 1 SRVNo FROM Sys_Setting WHERE SettingCode='RMRentFee'),'')
	SET @RMRentFeeSRVNo_DL = ISNULL((SELECT TOP 1 SRVNo FROM Sys_Setting WHERE SettingCode='RMRentFee_DL'),'')
	SET @WPRentFeeSRVNo = ISNULL((SELECT TOP 1 SRVNo FROM Sys_Setting WHERE SettingCode='WPRentFee'),'')
	SET @BBRentFeeSRVNo = ISNULL((SELECT TOP 1 SRVNo FROM Sys_Setting WHERE SettingCode='BBRentFee'),'')
	SET @AirConditionFeeSRVNo = ISNULL((SELECT TOP 1 SRVNo FROM Sys_Setting WHERE SettingCode='AirConditionFee'),'')
	SET @PropertyFeeSRVNo = ISNULL((SELECT TOP 1 SRVNo FROM Sys_Setting WHERE SettingCode='PropertyFee'),'')
	SET @ServiceChargeSRVNo = ISNULL((SELECT TOP 1 SRVNo FROM Sys_Setting WHERE SettingCode='ServiceCharge'),'')
	SET @SharedWaterFee = ISNULL((SELECT TOP 1 DecimalValue FROM Sys_Setting WHERE SettingCode='SharedWaterFee'),0)
	SET @WaterFee = ISNULL((SELECT TOP 1 DecimalValue FROM Sys_Setting WHERE SettingCode='WaterFee'),0)
	SET @ElectricFee = ISNULL((SELECT TOP 1 DecimalValue FROM Sys_Setting WHERE SettingCode='ElectricFee'),0)
	SET @WPOverElectricyPrice = ISNULL((SELECT TOP 1 DecimalValue FROM Sys_Setting WHERE SettingCode='OverElectricFee'),0)
	SET @SharedElectricFee = ISNULL((SELECT TOP 1 DecimalValue FROM Sys_Setting WHERE SettingCode='SharedElectricFee'),0)
				
	CREATE TABLE #TEMP(ContractID NVARCHAR(36),FeeMonth NVARCHAR(7))	
	EXEC('INSERT INTO #TEMP(ContractID,FeeMonth) SELECT ContractID,FeeMonth FROM ' + @TableName)
	
	CREATE TABLE #TEMP_CONTRACT(LINE INT IDENTITY(1,1),ContractID NVARCHAR(36),FeeMonth NVARCHAR(7),ContractType NVARCHAR(30))
	
	--��ѡ���ͬ���ա��ͻ����������塿������ͬ���͡������·ݡ����ࡣ
	SELECT IDENTITY(INT,1,1) AS LINE,B.ContractSPNo,B.ContractCustNo,B.ContractType,A.FeeMonth
	INTO #TEMP_CUST
	FROM #TEMP A LEFT JOIN 
	Op_Contract B ON A.ContractID=B.RowPointer
	GROUP BY B.ContractSPNo,B.ContractCustNo,B.ContractType,A.FeeMonth
	
	BEGIN TRAN TR_OP
	
		SET @DateNow = GETDATE()
			
		SET @K = 1
		SET @MAXK = ISNULL((SELECT MAX(LINE) FROM #TEMP_CUST),0)
		WHILE (@K <= @MAXK)
		BEGIN
			SELECT @CustNo=ContractCustNo,@SPNo=ContractSPNo,@ContractType=ContractType,@FeeMonth=FeeMonth 
			FROM #TEMP_CUST WHERE LINE=@K
		
			TRUNCATE TABLE #TEMP_CONTRACT
			
			INSERT INTO #TEMP_CONTRACT(ContractID,FeeMonth)
			SELECT A.ContractID,A.FeeMonth FROM #TEMP A LEFT JOIN Op_Contract B ON A.ContractID=B.RowPointer
			WHERE B.ContractCustNo=@CustNo AND B.ContractSPNo=@SPNo
			
			----------��������----------
			SET @OrderDate = @FeeMonth + '-01'
			SET @DaysofMonth = DAY(DATEADD(DAY,-1,DATEADD(MONTH,1,@OrderDate)))				
			SET @OrderID = NEWID()
			SET @OrderNo = REPLACE(CONVERT(NVARCHAR(7),GETDATE(),121),'-','')
			SELECT @NewNo = MAX(OrderNo) FROM Op_OrderHeader WHERE OrderNo LIKE @OrderNo +'%'   
			IF @NewNo IS NULL
				SET @OrderNo = CONVERT(NVARCHAR(30),CONVERT(bigint,@OrderNo)) + '00001'
			ELSE
				SET @OrderNo = CONVERT(NVARCHAR(30),CONVERT(bigint,@NewNo)+1)
				
			INSERT INTO Op_OrderHeader(RowPointer,OrderNo,OrderType,CustNo,OrderTime,DaysofMonth,ARDate,ARAmount,
				ReduceAmount,PaidinAmount,OrderAuditor,OrderAuditDate,OrderAuditReason,OrderRAuditor,OrderRAuditDate,
				OrderRAuditReason,Remark,OrderStatus,OrderCreator,OrderCreateDate,OrderLastReviser,OrderLastRevisedDate)
			VALUES(@OrderID,@OrderNo,@ContractType,@CustNo,@OrderDate,@DaysofMonth,DATEADD(DAY,4,@OrderDate),0,
				0,0,'',NULL,'','',NULL,'','','0',@UserName,@DateNow,@UserName,@DateNow)
			IF @@ERROR != 0 GOTO Error_Exit
			----------��������----------
			
			SET @I = 1
			SET @MAXI = ISNULL((SELECT MAX(LINE) FROM #TEMP_CONTRACT),0)
			WHILE (@I <= @MAXI)
			BEGIN
			
				SELECT  @ContractID = A.ContractID, 
						@WPElectricyLimit = B.WPElectricyLimit
				FROM #TEMP_CONTRACT A LEFT JOIN Op_Contract B ON A.ContractID=B.RowPointer 
				WHERE lINE = @I
	  			 
				--������ϸ���������
				IF(@ContractType = '01')
				BEGIN
					INSERT INTO Op_OrderDetail(RowPointer,RefRP,ODSRVTypeNo1,ODSRVTypeNo2,ODSRVNo,ODSRVRemark,ODSRVCalType,ODContractSPNo,
						ODContractNo,ODContractNoManual,ResourceNo,ResourceName,ODFeeStartDate,ODFeeEndDate,BillingDays,
						ODQTY,ODUnit,ODUnitPrice,ODARAmount,
						ODCANo,ODCreator,ODCreateDate,ODLastReviser,ODLastRevisedDate,RefNo,ODTaxRate,ODTaxAmount,ReduceAmount)
					SELECT NEWID(),@OrderID,C.SRVTypeNo1,C.SRVTypeNo2,A.SRVNo,'',C.SRVCalType,B.ContractSPNo,
						B.ContractNo,B.ContractNoManual,A.RMID,'����ţ�'+D.RMNO,a.FeeStartDate,a.FeeEndDate,
						DATEDIFF(DAY,A.FeeStartDate,A.FeeEndDate)+1,
						A.FeeQty,'ƽ��',A.FeeUnitPrice,A.FeeAmount,C.CANo,@UserName,@DateNow,@UserName,@DateNow,A.RowPointer,
						ISNULL(F.Rate,0),A.FeeAmount - ROUND((A.FeeAmount / (1+ISNULL(F.Rate,0))),2),0
					FROM Op_ContractRMRentList A 
						LEFT JOIN Op_Contract B ON A.RefRP=B.RowPointer
						LEFT JOIN Mstr_Service C ON C.SRVNo=A.SRVNo
						LEFT JOIN Mstr_Room D ON D.RMID=A.RMID
						LEFT JOIN Mstr_TaxRate F ON F.SRVNo = A.SRVNo AND F.SPNo=B.ContractSPNo
					WHERE B.RowPointer = @ContractID
						AND A.FeeStatus='0'
						AND CONVERT(NVARCHAR(7),A.FeeStartDate,121) = @FeeMonth
						AND A.SRVNo IN (@RMRentFeeSRVNo,@RMRentFeeSRVNo_DL)
					IF @@ERROR != 0 GOTO Error_Exit
				END
					
				--������ϸ����λ���/��λ����ѣ�
				ELSE IF(@ContractType = '02')
				BEGIN
					INSERT INTO Op_OrderDetail(RowPointer,RefRP,ODSRVTypeNo1,ODSRVTypeNo2,ODSRVNo,ODSRVRemark,ODSRVCalType,ODContractSPNo,
						ODContractNo,ODContractNoManual,ResourceNo,ResourceName,ODFeeStartDate,ODFeeEndDate,BillingDays,
						ODQTY,ODUnit,ODUnitPrice,ODARAmount,
						ODCANo,ODCreator,ODCreateDate,ODLastReviser,ODLastRevisedDate,RefNo,ODTaxRate,ODTaxAmount,ReduceAmount)
					SELECT NEWID(),@OrderID,C.SRVTypeNo1,C.SRVTypeNo2,A.SRVNo,'',C.SRVCalType,B.ContractSPNo,
						B.ContractNo,B.ContractNoManual,A.WPNo,'��λ:'+E.WPTypeName,a.FeeStartDate,a.FeeEndDate,
						DATEDIFF(DAY,A.FeeStartDate,A.FeeEndDate)+1,
						A.FeeQty,'��',A.FeeUnitPrice,A.FeeAmount,C.CANo,@UserName,@DateNow,@UserName,@DateNow,A.RowPointer,
						ISNULL(F.Rate,0),A.FeeAmount - ROUND((A.FeeAmount / (1+ISNULL(F.Rate,0))),2),0
					FROM Op_ContractRMRentList A 
						LEFT JOIN Op_Contract B ON A.RefRP=B.RowPointer
						LEFT JOIN Mstr_Service C ON C.SRVNo=A.SRVNo
						LEFT JOIN Mstr_WorkPlace D ON D.WPNo=A.WPNo
						LEFT JOIN Mstr_WorkPlaceType E ON E.WPTypeNo=D.WPType
						LEFT JOIN Mstr_TaxRate F ON F.SRVNo = A.SRVNo AND F.SPNo=B.ContractSPNo
					WHERE B.RowPointer = @ContractID
						AND A.FeeStatus='0'
						AND CONVERT(NVARCHAR(7),A.FeeStartDate,121) = @FeeMonth
						AND A.SRVNo = @WPRentFeeSRVNo
					IF @@ERROR != 0 GOTO Error_Exit	
					
					INSERT INTO Op_OrderDetail(RowPointer,RefRP,ODSRVTypeNo1,ODSRVTypeNo2,ODSRVNo,ODSRVRemark,ODSRVCalType,ODContractSPNo,
						ODContractNo,ODContractNoManual,ResourceNo,ResourceName,ODFeeStartDate,ODFeeEndDate,BillingDays,
						ODQTY,ODUnit,ODUnitPrice,ODARAmount,
						ODCANo,ODCreator,ODCreateDate,ODLastReviser,ODLastRevisedDate,RefNo,ODTaxRate,ODTaxAmount,ReduceAmount)
					SELECT NEWID(),@OrderID,C.SRVTypeNo1,C.SRVTypeNo2,A.SRVNo,'',C.SRVCalType,B.ContractSPNo,
						B.ContractNo,B.ContractNoManual,A.WPNo,'��λ:'+E.WPTypeName,a.FeeStartDate,a.FeeEndDate,
						DATEDIFF(DAY,A.FeeStartDate,A.FeeEndDate)+1,
						A.FeeQty,'��',A.FeeUnitPrice,A.FeeAmount,C.CANo,@UserName,@DateNow,@UserName,@DateNow,A.RowPointer,
						ISNULL(F.Rate,0),A.FeeAmount - ROUND((A.FeeAmount / (1+ISNULL(F.Rate,0))),2),0
					FROM Op_ContractRMRentList A 
						LEFT JOIN Op_Contract B ON A.RefRP=B.RowPointer
						LEFT JOIN Mstr_Service C ON C.SRVNo=A.SRVNo
						LEFT JOIN Mstr_WorkPlace D ON D.WPNo=A.WPNo
						LEFT JOIN Mstr_WorkPlaceType E ON E.WPTypeNo=D.WPType
						LEFT JOIN Mstr_TaxRate F ON F.SRVNo = A.SRVNo AND F.SPNo=B.ContractSPNo
					WHERE B.RowPointer = @ContractID
						AND A.FeeStatus='0'
						AND CONVERT(NVARCHAR(7),A.FeeStartDate,121) = @FeeMonth
						AND A.SRVNo = @WPSFSRVNo
					IF @@ERROR != 0 GOTO Error_Exit	
					
					
				END
					
				--������ϸ�����λ���
				ELSE IF(@ContractType = '03')
				BEGIN
					INSERT INTO Op_OrderDetail(RowPointer,RefRP,ODSRVTypeNo1,ODSRVTypeNo2,ODSRVNo,ODSRVRemark,ODSRVCalType,ODContractSPNo,
						ODContractNo,ODContractNoManual,ResourceNo,ResourceName,ODFeeStartDate,ODFeeEndDate,BillingDays,
						ODQTY,ODUnit,ODUnitPrice,ODARAmount,
						ODCANo,ODCreator,ODCreateDate,ODLastReviser,ODLastRevisedDate,RefNo,ODTaxRate,ODTaxAmount,ReduceAmount)
					SELECT NEWID(),@OrderID,C.SRVTypeNo1,C.SRVTypeNo2,A.SRVNo,'',C.SRVCalType,B.ContractSPNo,
						B.ContractNo,B.ContractNoManual,A.RMID,'���λ:'+d.BBName,a.FeeStartDate,a.FeeEndDate,
						DATEDIFF(DAY,a.FeeStartDate,a.FeeEndDate)+1,
						A.FeeQty,'��',A.FeeUnitPrice,A.FeeAmount,C.CANo,@UserName,@DateNow,@UserName,@DateNow,A.RowPointer,
						ISNULL(F.Rate,0),A.FeeAmount - ROUND((A.FeeAmount / (1+ISNULL(F.Rate,0))),2),0
					FROM Op_ContractRMRentList A 
						LEFT JOIN Op_Contract B ON A.RefRP=B.RowPointer
						LEFT JOIN Mstr_Service C ON C.SRVNo=A.SRVNo
						LEFT JOIN Mstr_Billboard D ON D.BBNo=A.RMID
						LEFT JOIN Mstr_TaxRate F ON F.SRVNo = A.SRVNo AND F.SPNo=B.ContractSPNo
					WHERE B.RowPointer = @ContractID
						AND A.FeeStatus='0'
						AND CONVERT(NVARCHAR(7),A.FeeStartDate,121) = @FeeMonth
						AND A.SRVNo = @BBRentFeeSRVNo
					IF @@ERROR != 0 GOTO Error_Exit
				END
					
				--������ϸ�������/�յ���/�̶������/ˮ�磩
				ELSE IF(@ContractType = '04')
				BEGIN
					--����ѡ��յ��ѡ��̶������
					INSERT INTO Op_OrderDetail(RowPointer,RefRP,ODSRVTypeNo1,ODSRVTypeNo2,ODSRVNo,ODSRVRemark,ODSRVCalType,ODContractSPNo,
						ODContractNo,ODContractNoManual,ResourceNo,ResourceName,ODFeeStartDate,ODFeeEndDate,BillingDays,
						ODQTY,ODUnit,ODUnitPrice,ODARAmount,
						ODCANo,ODCreator,ODCreateDate,ODLastReviser,ODLastRevisedDate,RefNo,ODTaxRate,ODTaxAmount,ReduceAmount)
					SELECT NEWID(),@OrderID,C.SRVTypeNo1,C.SRVTypeNo2,A.SRVNo,'',C.SRVCalType,B.ContractSPNo,
						B.ContractNo,B.ContractNoManual,A.RMID,C.SRVName,a.FeeStartDate,a.FeeEndDate,
						DATEDIFF(DAY,a.FeeStartDate,a.FeeEndDate)+1,
						A.FeeQty,'ƽ��',a.FeeUnitPrice,
						A.FeeAmount,C.CANo,@UserName,@DateNow,@UserName,@DateNow,A.RowPointer,
						ISNULL(F.Rate,0),A.FeeAmount - ROUND((A.FeeAmount / (1+ISNULL(F.Rate,0))),2),0
					FROM Op_ContractRMRentList A 
						LEFT JOIN Op_Contract B ON A.RefRP=B.RowPointer
						LEFT JOIN Mstr_Service C ON C.SRVNo=A.SRVNo
						LEFT JOIN Mstr_Room D ON D.RMID=A.RMID
						LEFT JOIN Mstr_TaxRate F ON F.SRVNo = A.SRVNo AND F.SPNo=B.ContractSPNo
					WHERE B.RowPointer = @ContractID
						AND A.FeeStatus='0'
						AND ISNULL(A.IsRefund,0) = 0
						AND CONVERT(NVARCHAR(7),A.FeeStartDate,121) = @FeeMonth
						AND A.SRVNo IN(@AirConditionFeeSRVNo,@PropertyFeeSRVNo,@ServiceChargeSRVNo)
					IF @@ERROR != 0 GOTO Error_Exit
						
					
					
					-----------------�޸ĳ������ݵ�������ϸ-------------------
					IF EXISTS(SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID=OBJECT_ID('TEMPDB..#TEMP2'))
						DROP TABLE #TEMP2
					
					SELECT IDENTITY(INT,1,1) AS LINE,A.RowPointer,A.RMID,A.SRVNo,A.FeeStartDate
					INTO #TEMP2 
					FROM Op_ContractRMRentList A 
						LEFT JOIN Op_Contract B ON A.RefRP=B.RowPointer
					WHERE B.RowPointer = @ContractID
						AND A.FeeStatus='0'
						AND ISNULL(A.IsRefund,0) = 0
						AND CONVERT(NVARCHAR(7),DateAdd(MONTH,1,A.FeeStartDate),121) = @FeeMonth
						AND A.SRVNo IN (@WaterFeeSRVNo,@ElectricFeeSRVNo,@SharedWaterFeeSRVNo)
					
					SET @J=1
					SET @MAXJ = ISNULL((SELECT MAX(LINE) FROM #TEMP2),0)
					WHILE(@J<=@MAXJ)
					BEGIN
						SELECT @RentRP=RowPointer,@RentRMID=RMID,@RentSRVNo=SRVNo,@FeeStartDate=FeeStartDate FROM #TEMP2 WHERE LINE= @J
						
						IF(@RentSRVNo=@WaterFeeSRVNo) --ˮ��
						BEGIN
						
							UPDATE Op_ContractRMRentList 
							SET LastReadout = ISNULL((SELECT TOP 1 M.LastReadout FROM Op_Readout M 
													LEFT JOIN Mstr_Meter N ON M.MeterNo=N.MeterNo 
													WHERE N.MeterType='wm' AND M.AuditStatus='1' AND M.IsOrder=0 AND 
														M.ReadoutType<>'0' AND M.RMID=@RentRMID ORDER BY AuditDate),0)
							WHERE RowPointer=@RentRP
							IF @@ERROR != 0 GOTO Error_Exit
						
							UPDATE Op_ContractRMRentList 
							SET Readout = ISNULL((SELECT TOP 1 M.Readout FROM Op_Readout M 
													LEFT JOIN Mstr_Meter N ON M.MeterNo=N.MeterNo 
													WHERE N.MeterType='wm' AND M.AuditStatus='1' AND M.IsOrder=0 AND 
														M.ReadoutType<>'0' AND M.RMID=@RentRMID ORDER BY AuditDate DESC),0)
							WHERE RowPointer=@RentRP
							IF @@ERROR != 0 GOTO Error_Exit
							
							UPDATE Op_ContractRMRentList 
							SET FeeQty = ISNULL((SELECT SUM((M.Readings+M.OldMeterReadings)*N.MeterRate) FROM Op_Readout M 
													LEFT JOIN Mstr_Meter N ON M.MeterNo=N.MeterNo 
													WHERE N.MeterType='wm' AND M.AuditStatus='1' AND M.IsOrder=0 AND M.ReadoutType<>'0' AND M.RMID=@RentRMID),0)
							WHERE RowPointer=@RentRP
							IF @@ERROR != 0 GOTO Error_Exit
												
							--�޸�ˮ�Ѽ۸�Ϊ��ǰ����
							UPDATE Op_ContractRMRentList
							SET FeeUnitPrice=@WaterFee
							WHERE RowPointer=@RentRP
							IF @@ERROR != 0 GOTO Error_Exit
							
							IF(@WaterFeeRoundType = 'ceiling')
							BEGIN
								UPDATE Op_ContractRMRentList
								SET FeeAmount=CEILING(FeeQty*FeeUnitPrice)
								WHERE RowPointer=@RentRP
								IF @@ERROR != 0 GOTO Error_Exit
							END
							ELSE IF(@WaterFeeRoundType = 'floor')
							BEGIN
								UPDATE Op_ContractRMRentList
								SET FeeAmount=FLOOR(FeeQty*FeeUnitPrice)
								WHERE RowPointer=@RentRP
								IF @@ERROR != 0 GOTO Error_Exit
							END
							ELSE
							BEGIN
								UPDATE Op_ContractRMRentList
								SET FeeAmount=ROUND(FeeQty*FeeUnitPrice,@WaterFeeDecimalPoint)
								WHERE RowPointer=@RentRP
								IF @@ERROR != 0 GOTO Error_Exit
							END
						
							INSERT INTO Op_ContractRMRentList_Readout(RowPointer,RefRentRP,RefReadoutRP,RMID,Creator,CreateDate)
							SELECT NEWID(),@RentRP,RowPointer,@RentRMID,@UserName,@DateNow
							FROM Op_Readout M 
								LEFT JOIN Mstr_Meter N ON M.MeterNo=N.MeterNo 
							WHERE N.MeterType='wm' AND M.AuditStatus='1' AND M.IsOrder=0 AND M.ReadoutType<>'0' AND M.RMID=@RentRMID
							IF @@ERROR != 0 GOTO Error_Exit	
							
							--�޸ĳ����¼״̬
							UPDATE Op_Readout SET IsOrder=1
							FROM Mstr_Meter A
							WHERE A.MeterNo=Op_Readout.MeterNo AND A.MeterType='wm' 
								AND Op_Readout.IsOrder=0 AND Op_Readout.AuditStatus='1' AND Op_Readout.ReadoutType<>'0' AND Op_Readout.RMID=@RentRMID	
							IF @@ERROR != 0 GOTO Error_Exit	
							
						END
						ELSE IF(@RentSRVNo=@SharedWaterFeeSRVNo) --��̯ˮ��
						BEGIN
							--UPDATE Op_ContractRMRentList 
							--SET FeeQty = A.RMRentSize
							--FROM Mstr_Room A
							--WHERE A.RMID=Op_ContractRMRentList.RMID AND RowPointer = @RentRP	
				
							UPDATE Op_ContractRMRentList 
							SET FeeQty = A.RMArea
							FROM Op_ContractPropertyFee A
							WHERE A.RowPointer=Op_ContractRMRentList.RefNo AND Op_ContractRMRentList.RowPointer=@RentRP
							IF @@ERROR != 0 GOTO Error_Exit
												
							--�޸Ĺ�̯ˮ�Ѽ۸�Ϊ��ǰ����
							UPDATE Op_ContractRMRentList
							SET FeeUnitPrice=@SharedWaterFee
							WHERE RowPointer=@RentRP
							IF @@ERROR != 0 GOTO Error_Exit
							
							SET @NaturalDays = DAY(DATEADD(DAY,-DAY(DATEADD(MONTH,1,@FeeStartDate)),DATEADD(MONTH,1,@FeeStartDate)))											
							IF(@SharedWaterRoundType = 'ceiling')
							BEGIN
								UPDATE Op_ContractRMRentList
								SET FeeAmount=CEILING(ROUND(FeeUnitPrice*FeeQty*(DATEDIFF(DAY,FeeStartDate,FeeEndDate)+1)/@NaturalDays,5))
								WHERE RowPointer=@RentRP
								IF @@ERROR != 0 GOTO Error_Exit
							END
							ELSE IF(@SharedWaterRoundType = 'floor')
							BEGIN
								UPDATE Op_ContractRMRentList
								SET FeeAmount=FLOOR(ROUND(FeeUnitPrice*FeeQty*(DATEDIFF(DAY,FeeStartDate,FeeEndDate)+1)/@NaturalDays,5))
								WHERE RowPointer=@RentRP
								IF @@ERROR != 0 GOTO Error_Exit
							END
							ELSE
							BEGIN
								UPDATE Op_ContractRMRentList
								SET FeeAmount=ROUND(ROUND(FeeUnitPrice*FeeQty*(DATEDIFF(DAY,FeeStartDate,FeeEndDate)+1)/@NaturalDays,5),@SharedWaterDecimalPoint)
								WHERE RowPointer=@RentRP
								IF @@ERROR != 0 GOTO Error_Exit
							END					
						END
						ELSE IF(@RentSRVNo=@ElectricFeeSRVNo) --���
						BEGIN
						
							UPDATE Op_ContractRMRentList 
							SET LastReadout = ISNULL((SELECT TOP 1 M.LastReadout FROM Op_Readout M 
													LEFT JOIN Mstr_Meter N ON M.MeterNo=N.MeterNo 
													WHERE N.MeterType='am' AND M.AuditStatus='1' AND M.IsOrder=0 AND 
														M.ReadoutType<>'0' AND M.RMID=@RentRMID ORDER BY AuditDate),0)
							WHERE RowPointer=@RentRP
							IF @@ERROR != 0 GOTO Error_Exit
						
							UPDATE Op_ContractRMRentList 
							SET Readout = ISNULL((SELECT TOP 1 M.Readout FROM Op_Readout M 
													LEFT JOIN Mstr_Meter N ON M.MeterNo=N.MeterNo 
													WHERE N.MeterType='am' AND M.AuditStatus='1' AND M.IsOrder=0 AND 
														M.ReadoutType<>'0' AND M.RMID=@RentRMID ORDER BY AuditDate DESC),0)
							WHERE RowPointer=@RentRP
							IF @@ERROR != 0 GOTO Error_Exit
							
							UPDATE Op_ContractRMRentList 
							SET FeeQty = ISNULL((SELECT SUM((M.Readings+M.OldMeterReadings)*N.MeterRate) FROM Op_Readout M 
													LEFT JOIN Mstr_Meter N ON M.MeterNo=N.MeterNo 
													WHERE N.MeterType='am' AND M.AuditStatus='1' AND M.IsOrder=0 AND M.ReadoutType<>'0' AND M.RMID=@RentRMID),0)
							WHERE RowPointer=@RentRP
							IF @@ERROR != 0 GOTO Error_Exit
												
							--�޸ĵ�Ѽ۸�Ϊ��ǰ����
							UPDATE Op_ContractRMRentList
							SET FeeUnitPrice=@ElectricFee
							WHERE RowPointer=@RentRP
							IF @@ERROR != 0 GOTO Error_Exit
									
							IF(@ElectricFeeRoundType = 'ceiling')
							BEGIN
								UPDATE Op_ContractRMRentList 
								SET FeeAmount = CEILING(FeeQty * FeeUnitPrice)
								WHERE RowPointer=@RentRP
								IF @@ERROR != 0 GOTO Error_Exit	
							END
							ELSE IF(@ElectricFeeRoundType = 'floor')
							BEGIN
								UPDATE Op_ContractRMRentList 
								SET FeeAmount = FLOOR(FeeQty * FeeUnitPrice)
								WHERE RowPointer=@RentRP
								IF @@ERROR != 0 GOTO Error_Exit
							END
							ELSE
							BEGIN
								UPDATE Op_ContractRMRentList 
								SET FeeAmount = ROUND(FeeQty * FeeUnitPrice,@ElectricFeeDecimalPoint)
								WHERE RowPointer=@RentRP
								IF @@ERROR != 0 GOTO Error_Exit
							END						
						
							INSERT INTO Op_ContractRMRentList_Readout(RowPointer,RefRentRP,RefReadoutRP,RMID,Creator,CreateDate)
							SELECT NEWID(),@RentRP,RowPointer,@RentRMID,@UserName,@DateNow
							FROM Op_Readout M 
								LEFT JOIN Mstr_Meter N ON M.MeterNo=N.MeterNo 
							WHERE N.MeterType='am' AND M.AuditStatus='1' AND M.IsOrder=0 AND M.ReadoutType<>'0' AND M.RMID=@RentRMID
							IF @@ERROR != 0 GOTO Error_Exit	
							
							--�޸ĳ����¼״̬
							UPDATE Op_Readout SET IsOrder=1
							FROM Mstr_Meter A
							WHERE A.MeterNo=Op_Readout.MeterNo AND A.MeterType='am' 
								AND Op_Readout.IsOrder=0 AND Op_Readout.AuditStatus='1' AND Op_Readout.ReadoutType<>'0' AND Op_Readout.RMID=@RentRMID	
							IF @@ERROR != 0 GOTO Error_Exit	
						END
						
						SET @J = @J + 1
					END
					
					IF EXISTS(SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID=OBJECT_ID('TEMPDB..#TEMP3'))
						DROP TABLE #TEMP3
					
					SELECT IDENTITY(INT,1,1) AS LINE,A.RowPointer,A.RMID,A.SRVNo,A.FeeStartDate
					INTO #TEMP3 
					FROM Op_ContractRMRentList A 
						LEFT JOIN Op_Contract B ON A.RefRP=B.RowPointer
					WHERE B.RowPointer = @ContractID
						AND CONVERT(NVARCHAR(7),DateAdd(MONTH,1,A.FeeStartDate),121) = @FeeMonth
						AND A.SRVNo = @SharedElectricFeeSRVNo
					
					SET @J=1
					SET @MAXJ = ISNULL((SELECT MAX(LINE) FROM #TEMP3),0)
					WHILE(@J<=@MAXJ)
					BEGIN
						SELECT @RentRP=RowPointer,@RentRMID=RMID,@RentSRVNo=SRVNo,@FeeStartDate=FeeStartDate FROM #TEMP3 WHERE LINE= @J
						
						IF(@RentSRVNo=@SharedElectricFeeSRVNo) --��̯��� - ���õ�Ѷ��������¡���ǰ���䣩
						BEGIN
						
							UPDATE Op_ContractRMRentList 
							SET LastReadout = ISNULL((SELECT TOP 1 LastReadout FROM Op_ContractRMRentList 
													WHERE RefRP=@ContractID AND SRVNo = @ElectricFeeSRVNo 
														AND RMID=@RentRMID AND FeeStartDate=@FeeStartDate),0)
							WHERE RowPointer=@RentRP
							IF @@ERROR != 0 GOTO Error_Exit
						
							UPDATE Op_ContractRMRentList 
							SET Readout = ISNULL((SELECT TOP 1 Readout FROM Op_ContractRMRentList 
													WHERE RefRP=@ContractID AND SRVNo = @ElectricFeeSRVNo 
														AND RMID=@RentRMID AND FeeStartDate=@FeeStartDate),0)
							WHERE RowPointer=@RentRP
							IF @@ERROR != 0 GOTO Error_Exit
							
							UPDATE Op_ContractRMRentList 
							SET FeeQty = ISNULL((SELECT TOP 1 FeeQty FROM Op_ContractRMRentList 
													WHERE RefRP=@ContractID AND SRVNo = @ElectricFeeSRVNo 
														AND RMID=@RentRMID AND FeeStartDate=@FeeStartDate),0)
							WHERE RowPointer=@RentRP
							IF @@ERROR != 0 GOTO Error_Exit
												
							--�޸ĵ�Ѽ۸�Ϊ��ǰ����
							UPDATE Op_ContractRMRentList
							SET FeeUnitPrice=@SharedElectricFee
							WHERE RowPointer=@RentRP
							IF @@ERROR != 0 GOTO Error_Exit
									
							IF(@SharedElectricFeeRoundType = 'ceiling')
							BEGIN
								UPDATE Op_ContractRMRentList 
								SET FeeAmount = CEILING(FeeQty * FeeUnitPrice)
								WHERE RowPointer=@RentRP
								IF @@ERROR != 0 GOTO Error_Exit	
							END
							ELSE IF(@SharedElectricFeeRoundType = 'floor')
							BEGIN
								UPDATE Op_ContractRMRentList 
								SET FeeAmount = FLOOR(FeeQty * FeeUnitPrice)
								WHERE RowPointer=@RentRP
								IF @@ERROR != 0 GOTO Error_Exit
							END
							ELSE
							BEGIN
								UPDATE Op_ContractRMRentList 
								SET FeeAmount = ROUND(FeeQty * FeeUnitPrice,@SharedElectricFeeDecimalPoint)
								WHERE RowPointer=@RentRP
								IF @@ERROR != 0 GOTO Error_Exit
							END
						END
						
						SET @J = @J + 1
					END
					-----------------�޸ĳ������ݵ�������ϸ-------------------
					
					
					--�߱�ˮ��
					INSERT INTO Op_OrderDetail(RowPointer,RefRP,ODSRVTypeNo1,ODSRVTypeNo2,ODSRVNo,ODSRVRemark,ODSRVCalType,ODContractSPNo,
						ODContractNo,ODContractNoManual,ResourceNo,ResourceName,ODFeeStartDate,ODFeeEndDate,BillingDays,
						ODQTY,ODUnit,ODUnitPrice,ODARAmount,
						ODCANo,ODCreator,ODCreateDate,ODLastReviser,ODLastRevisedDate,RefNo,ODTaxRate,ODTaxAmount,LastReadout,Readout,ReduceAmount)
					SELECT NEWID(),@OrderID,C.SRVTypeNo1,C.SRVTypeNo2,A.SRVNo,'',C.SRVCalType,B.ContractSPNo,
						B.ContractNo,B.ContractNoManual,A.RMID,D.RMNO+'����ˮ��',a.FeeStartDate,a.FeeEndDate,
						DATEDIFF(DAY,a.FeeStartDate,a.FeeEndDate)+1,
						A.FeeQty,'��',A.FeeUnitPrice,A.FeeAmount,C.CANo,@UserName,@DateNow,@UserName,@DateNow,A.RowPointer,
						ISNULL(F.Rate,0),A.FeeAmount - ROUND((A.FeeAmount / (1+ISNULL(F.Rate,0))),2),A.LastReadout,A.Readout,0
					FROM Op_ContractRMRentList A 
						LEFT JOIN Op_Contract B ON A.RefRP=B.RowPointer
						LEFT JOIN Mstr_Service C ON C.SRVNo=A.SRVNo
						LEFT JOIN Mstr_Room D ON D.RMID=A.RMID
						LEFT JOIN Mstr_TaxRate F ON F.SRVNo = A.SRVNo AND F.SPNo=B.ContractSPNo
					WHERE B.RowPointer = @ContractID
						AND A.FeeStatus='0'
						AND ISNULL(A.IsRefund,0) = 0
						AND CONVERT(NVARCHAR(7),DateAdd(MONTH,1,A.FeeStartDate),121) = @FeeMonth
						AND A.SRVNo = @WaterFeeSRVNo
					IF @@ERROR != 0 GOTO Error_Exit	
					
					--��̯ˮ�ѡ���̯����*�������*�Ʒ�����/��Ȼ��������
					INSERT INTO Op_OrderDetail(RowPointer,RefRP,ODSRVTypeNo1,ODSRVTypeNo2,ODSRVNo,ODSRVRemark,ODSRVCalType,ODContractSPNo,
						ODContractNo,ODContractNoManual,ResourceNo,ResourceName,ODFeeStartDate,ODFeeEndDate,BillingDays,
						ODQTY,ODUnit,ODUnitPrice,ODARAmount,
						ODCANo,ODCreator,ODCreateDate,ODLastReviser,ODLastRevisedDate,RefNo,ODTaxRate,ODTaxAmount,ReduceAmount)
					SELECT NEWID(),@OrderID,C.SRVTypeNo1,C.SRVTypeNo2,A.SRVNo,'',C.SRVCalType,B.ContractSPNo,
						B.ContractNo,B.ContractNoManual,A.RMID,D.RMNO+'���乫̯ˮ��',a.FeeStartDate,a.FeeEndDate,
						DATEDIFF(DAY,a.FeeStartDate,a.FeeEndDate)+1,
						A.FeeQty,'ƽ��',A.FeeUnitPrice,A.FeeAmount,C.CANo,@UserName,@DateNow,@UserName,@DateNow,A.RowPointer,
						ISNULL(F.Rate,0),A.FeeAmount - ROUND((A.FeeAmount / (1+ISNULL(F.Rate,0))),2),0
					FROM Op_ContractRMRentList A 
						LEFT JOIN Op_Contract B ON A.RefRP=B.RowPointer
						LEFT JOIN Mstr_Service C ON C.SRVNo=A.SRVNo
						LEFT JOIN Mstr_Room D ON D.RMID=A.RMID
						LEFT JOIN Mstr_TaxRate F ON F.SRVNo = A.SRVNo AND F.SPNo=B.ContractSPNo
					WHERE B.RowPointer = @ContractID
						AND A.FeeStatus='0'
						AND ISNULL(A.IsRefund,0) = 0
						AND CONVERT(NVARCHAR(7),DateAdd(MONTH,1,A.FeeStartDate),121) = @FeeMonth
						AND A.SRVNo = @SharedWaterFeeSRVNo
					IF @@ERROR != 0 GOTO Error_Exit		
									
					--�߱���
					INSERT INTO Op_OrderDetail(RowPointer,RefRP,ODSRVTypeNo1,ODSRVTypeNo2,ODSRVNo,ODSRVRemark,ODSRVCalType,ODContractSPNo,
						ODContractNo,ODContractNoManual,ResourceNo,ResourceName,ODFeeStartDate,ODFeeEndDate,BillingDays,
						ODQTY,ODUnit,ODUnitPrice,ODARAmount,
						ODCANo,ODCreator,ODCreateDate,ODLastReviser,ODLastRevisedDate,RefNo,ODTaxRate,ODTaxAmount,LastReadout,Readout,ReduceAmount)
					SELECT NEWID(),@OrderID,C.SRVTypeNo1,C.SRVTypeNo2,A.SRVNo,'',C.SRVCalType,B.ContractSPNo,
						B.ContractNo,B.ContractNoManual,A.RMID,D.RMNO+'������',a.FeeStartDate,a.FeeEndDate,
						DATEDIFF(DAY,a.FeeStartDate,a.FeeEndDate)+1,
						A.FeeQty,'��',A.FeeUnitPrice,A.FeeAmount,C.CANo,@UserName,@DateNow,@UserName,@DateNow,A.RowPointer,
						ISNULL(F.Rate,0),A.FeeAmount - ROUND((A.FeeAmount / (1+ISNULL(F.Rate,0))),2),A.LastReadout,A.Readout,0
					FROM Op_ContractRMRentList A 
						LEFT JOIN Op_Contract B ON A.RefRP=B.RowPointer
						LEFT JOIN Mstr_Service C ON C.SRVNo=A.SRVNo
						LEFT JOIN Mstr_Room D ON D.RMID=A.RMID
						LEFT JOIN Mstr_TaxRate F ON F.SRVNo = A.SRVNo AND F.SPNo=B.ContractSPNo
					WHERE B.RowPointer = @ContractID
						AND A.FeeStatus='0'
						AND ISNULL(A.IsRefund,0) = 0
						AND CONVERT(NVARCHAR(7),DateAdd(MONTH,1,A.FeeStartDate),121) = @FeeMonth
						AND A.SRVNo = @ElectricFeeSRVNo
					IF @@ERROR != 0 GOTO Error_Exit	
						
					--��̯��ѡ���ѵ���*ʵ�ö���*����*10%��
					INSERT INTO Op_OrderDetail(RowPointer,RefRP,ODSRVTypeNo1,ODSRVTypeNo2,ODSRVNo,ODSRVRemark,ODSRVCalType,ODContractSPNo,
						ODContractNo,ODContractNoManual,ResourceNo,ResourceName,ODFeeStartDate,ODFeeEndDate,BillingDays,
						ODQTY,ODUnit,ODUnitPrice,ODARAmount,
						ODCANo,ODCreator,ODCreateDate,ODLastReviser,ODLastRevisedDate,RefNo,ODTaxRate,ODTaxAmount,LastReadout,Readout,ReduceAmount)
					SELECT NEWID(),@OrderID,C.SRVTypeNo1,C.SRVTypeNo2,A.SRVNo,'',C.SRVCalType,B.ContractSPNo,
						B.ContractNo,B.ContractNoManual,A.RMID,D.RMNO+'���乫̯���',a.FeeStartDate,a.FeeEndDate,
						DATEDIFF(DAY,a.FeeStartDate,a.FeeEndDate)+1,
						A.FeeQty,'��',A.FeeUnitPrice,A.FeeAmount,C.CANo,@UserName,@DateNow,@UserName,@DateNow,A.RowPointer,
						ISNULL(F.Rate,0),A.FeeAmount - ROUND((A.FeeAmount / (1+ISNULL(F.Rate,0))),2),A.LastReadout,A.Readout,0
					FROM Op_ContractRMRentList A 
						LEFT JOIN Op_Contract B ON A.RefRP=B.RowPointer
						LEFT JOIN Mstr_Service C ON C.SRVNo=A.SRVNo
						LEFT JOIN Mstr_Room D ON D.RMID=A.RMID
						LEFT JOIN Mstr_TaxRate F ON F.SRVNo = A.SRVNo AND F.SPNo=B.ContractSPNo
					WHERE B.RowPointer = @ContractID
						AND A.FeeStatus='0'
						AND ISNULL(A.IsRefund,0) = 0
						AND CONVERT(NVARCHAR(7),DateAdd(MONTH,1,A.FeeStartDate),121) = @FeeMonth
						AND A.SRVNo = @SharedElectricFeeSRVNo
					IF @@ERROR != 0 GOTO Error_Exit
									
				END
				
				--������ϸ�������ѣ�
				ELSE IF(@ContractType = '12')
				BEGIN					
				
				-----------------�޸ĳ������ݵ�������ϸ-------------------
					IF EXISTS(SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID=OBJECT_ID('TEMPDB..#TEMP1'))
						DROP TABLE #TEMP1
						
					SET @FeeStartDate=( SELECT top 1 A.FeeStartDate 
					FROM Op_ContractRMRentList A 
						LEFT JOIN Op_Contract B ON A.RefRP=B.RowPointer
					WHERE B.RowPointer = @ContractID--��ͬ����
						AND A.SRVNo IN (@OverElectricFeeSRVNo)--���ñ���
					ORDER BY A.FeeStartDate)
					
					SELECT IDENTITY(INT,1,1) AS LINE,A.RowPointer,A.RMID,A.WPNo,A.SRVNo
					INTO #TEMP1 
					FROM Op_ContractRMRentList A 
						LEFT JOIN Op_Contract B ON A.RefRP=B.RowPointer
					WHERE B.RowPointer = @ContractID--��ͬ����
						AND A.FeeStatus='0'
						AND CONVERT(NVARCHAR(7),DateAdd(MONTH,1,A.FeeStartDate),121) = @FeeMonth
						AND A.SRVNo IN (@OverElectricFeeSRVNo)--���ñ���
						
					
					SET @J=1
					SET @MAXJ = ISNULL((SELECT MAX(LINE) FROM #TEMP1),0)
					WHILE(@J<=@MAXJ)
					BEGIN
						--��ȡһ����¼
						SELECT @RentRP=RowPointer,@RentRMID=RMID,@RentWPNo=WPNo,@RentSRVNo=SRVNo FROM #TEMP1 WHERE LINE= @J
						--��ȡ���ù�λ����
						SELECT @TotalWPQTY=SUM(WPSeat) FROM Mstr_WorkPlace WHERE WPRMID=@RentRMID AND WPStatus='use'
						--��ȡ��λ����
						SELECT @WPQTY =1 --WPSeat FROM Mstr_WorkPlace WHERE WPRMID=@RentRMID
						----��ȡ�õ籶��
						--SELECT @Multiples=MeterRate FROM Mstr_Meter WHERE MeterRMID=@RentRMID
						--���ڶ���						
						UPDATE Op_ContractRMRentList 
						SET LastReadout = ISNULL((SELECT TOP 1 LastReadout FROM Op_Readout M 
									LEFT JOIN Mstr_Meter N ON M.MeterNo=N.MeterNo 
									WHERE N.MeterType='am' AND M.AuditStatus='1' AND M.RMID=@RentRMID
									AND ReadoutType<>'0'
									AND AuditDate>@FeeStartDate
									AND RowPointer NOT IN(SELECT RefReadoutRP FROM Op_ContractRMRentList_Readout M  WHERE WPNo=@RentWPNo)
									ORDER BY AuditDate
									),0)
						WHERE RowPointer=@RentRP
						IF @@ERROR != 0 GOTO Error_Exit
						--���ڶ���
						UPDATE Op_ContractRMRentList 
						SET Readout = ISNULL((SELECT TOP 1 Readout FROM Op_Readout M 
									LEFT JOIN Mstr_Meter N ON M.MeterNo=N.MeterNo 
									WHERE N.MeterType='am' AND M.AuditStatus='1' AND M.RMID=@RentRMID
									AND ReadoutType<>'0'
									AND AuditDate>@FeeStartDate
									AND RowPointer NOT IN(SELECT RefReadoutRP FROM Op_ContractRMRentList_Readout M  WHERE WPNo=@RentWPNo)
									ORDER BY AuditDate DESC
									),0)
						WHERE RowPointer=@RentRP
						IF @@ERROR != 0 GOTO Error_Exit
							
						--�����õ����
						UPDATE Op_ContractRMRentList 
						SET FeeQty = ISNULL((SELECT SUM((M.Readings+M.OldMeterReadings)*N.MeterRate) FROM Op_Readout M 
									LEFT JOIN Mstr_Meter N ON M.MeterNo=N.MeterNo 
									WHERE N.MeterType='am' AND M.AuditStatus='1' AND M.RMID=@RentRMID
									AND ReadoutType<>'0'
									AND AuditDate>@FeeStartDate
									AND RowPointer NOT IN(SELECT RefReadoutRP FROM Op_ContractRMRentList_Readout M  WHERE WPNo=@RentWPNo)
									),0)
						WHERE RowPointer=@RentRP
						IF @@ERROR != 0 GOTO Error_Exit	
						
						UPDATE Op_ContractRMRentList 
						SET FeeQty = (FeeQty - @WPElectricyLimit*@TotalWPQTY)/@TotalWPQTY
						WHERE RowPointer=@RentRP
						IF @@ERROR != 0 GOTO Error_Exit	
						
						UPDATE Op_ContractRMRentList 
						SET FeeQty = 0
						WHERE RowPointer=@RentRP AND FeeQty<0
						IF @@ERROR != 0 GOTO Error_Exit	
						
						IF(@OverElectricFeeRoundType='ceiling')
						BEGIN
							UPDATE Op_ContractRMRentList 
							SET FeeAmount = CEILING(FeeQty*@WPOverElectricyPrice*@WPQTY)
							WHERE RowPointer=@RentRP AND FeeQty > 0
							IF @@ERROR != 0 GOTO Error_Exit	
						END
						ELSE IF(@OverElectricFeeRoundType='floor')
						BEGIN
							UPDATE Op_ContractRMRentList 
							SET FeeAmount = FLOOR(FeeQty*@WPOverElectricyPrice*@WPQTY)
							WHERE RowPointer=@RentRP AND FeeQty > 0
							IF @@ERROR != 0 GOTO Error_Exit	
						END
						ELSE
						BEGIN
							UPDATE Op_ContractRMRentList 
							SET FeeAmount = ROUND(FeeQty*@WPOverElectricyPrice*@WPQTY,@OverElectricFeeDecimalPoint)
							WHERE RowPointer=@RentRP AND FeeQty > 0
							IF @@ERROR != 0 GOTO Error_Exit	
						END
						
						INSERT INTO Op_ContractRMRentList_Readout(RowPointer,RefRentRP,RefReadoutRP,RMID,WPNo,Creator,CreateDate)
						SELECT NEWID(),@RentRP,RowPointer,@RentRMID,@RentWPNo,@UserName,@DateNow
						FROM Op_Readout M 
							LEFT JOIN Mstr_Meter N ON M.MeterNo=N.MeterNo 
						WHERE N.MeterType='am' AND M.AuditStatus='1' AND M.RMID=@RentRMID
							AND ReadoutType<>'0'
							AND AuditDate>@FeeStartDate
							AND RowPointer NOT IN(SELECT RefReadoutRP FROM Op_ContractRMRentList_Readout M  WHERE WPNo=@RentWPNo)
						IF @@ERROR != 0 GOTO Error_Exit	
						
						SET @J = @J + 1
					END
					-----------------�޸ĳ������ݵ�������ϸ-------------------
					
					--��λ�����ѣ��õ��� - ���ù�λ����WPQTY * ÿ��λ���WPElectricyLimit��* �����WPOverElectricyPrice/���ù�λ����*��λ��
					INSERT INTO Op_OrderDetail(RowPointer,RefRP,ODSRVTypeNo1,ODSRVTypeNo2,ODSRVNo,ODSRVRemark,ODSRVCalType,ODContractSPNo,
						ODContractNo,ODContractNoManual,ResourceNo,ResourceName,ODFeeStartDate,ODFeeEndDate,BillingDays,
						ODQTY,ODUnit,ODUnitPrice,ODARAmount,
						ODCANo,ODCreator,ODCreateDate,ODLastReviser,ODLastRevisedDate,RefNo,ODTaxRate,ODTaxAmount,LastReadout,Readout,ReduceAmount)
					SELECT NEWID(),@OrderID,C.SRVTypeNo1,C.SRVTypeNo2,A.SRVNo,'',C.SRVCalType,B.ContractSPNo,
						B.ContractNo,B.ContractNoManual,A.WPNo,E.WPTypeName+'������',a.FeeStartDate,a.FeeEndDate,
						DATEDIFF(DAY,A.FeeStartDate,A.FeeEndDate)+1,
						A.FeeQty,'��',@WPOverElectricyPrice,A.FeeAmount,												
						C.CANo,@UserName,@DateNow,@UserName,@DateNow,A.RowPointer,
						ISNULL(F.Rate,0),A.FeeAmount - ROUND((A.FeeAmount / (1+ISNULL(F.Rate,0))),2),A.LastReadout,A.Readout,0
					FROM Op_ContractRMRentList A 
						LEFT JOIN Op_Contract B ON A.RefRP=B.RowPointer
						LEFT JOIN Mstr_Service C ON C.SRVNo=A.SRVNo
						LEFT JOIN Mstr_WorkPlace D ON D.WPNo=A.WPNo
						LEFT JOIN Mstr_WorkPlaceType E ON E.WPTypeNo=D.WPType
						LEFT JOIN Mstr_TaxRate F ON F.SRVNo = A.SRVNo AND F.SPNo=B.ContractSPNo
					WHERE B.RowPointer = @ContractID
						AND A.FeeStatus='0'
						AND CONVERT(NVARCHAR(7),DateAdd(MONTH,1,A.FeeStartDate),121) = @FeeMonth
						AND A.SRVNo = @OverElectricFeeSRVNo
					IF @@ERROR != 0 GOTO Error_Exit					
					
					--�޸ĳ����¼״̬
					UPDATE Op_Readout SET IsOrder=1
					FROM Mstr_Meter A 
					WHERE A.MeterNo=Op_Readout.MeterNo AND A.MeterType='am' AND AuditStatus='1' 
						AND ReadoutType<>'0' AND IsOrder=0 AND RMID IN (SELECT RMID FROM #TEMP1)
				END
				
				
				--�޸ķ����嵥״̬
				UPDATE Op_ContractRMRentList SET FeeStatus='1'
				WHERE RowPointer IN (SELECT RefNo FROM Op_OrderDetail WHERE RefRP=@OrderID)
				IF @@ERROR != 0 GOTO Error_Exit
				
				
				UPDATE Op_OrderHeader SET ARAmount=ISNULL((SELECT SUM(ODARAmount) FROM Op_OrderDetail WHERE RefRP=Op_OrderHeader.RowPointer),0)
				WHERE RowPointer=@OrderID
				IF @@ERROR != 0 GOTO Error_Exit
				
				DELETE FROM Op_OrderHeader
				WHERE RowPointer=@OrderID AND (SELECT COUNT(1) FROM Op_OrderDetail WHERE RefRP=Op_OrderHeader.RowPointer)=0
				IF @@ERROR != 0 GOTO Error_Exit
								
				SET @I = @I + 1
			END

			SET @K = @K + 1
		END
		
		
	COMMIT TRAN TR_OP
	SET @InfoMsg = ''
	EXEC('DROP TABLE ' + @TableName)
	RETURN 1  

Error_Exit:
BEGIN	
    ROLLBACK TRAN TR_OP
	EXEC('DROP TABLE ' + @TableName)
    if(@InfoMsg='') SET @InfoMsg = '���ݴ����쳣��'
	RETURN -1
END


GO



ALTER PROCEDURE [dbo].[DeleteOrder]
  @OrderID			NVARCHAR(36),
  @InfoMsg			NVARCHAR(500) output
AS

	DECLARE @NewMeterNo NVARCHAR(30),
			@OldMeterNo NVARCHAR(30),
			@AuditStatus NVARCHAR(30),
			@MeterReadout DECIMAL(15,4)

	BEGIN TRAN TR_OP 
	
		if not exists(select 1 from Op_OrderHeader WHERE RowPointer=@OrderID)
		begin
			SET @InfoMsg = '��ǰ��¼ϵͳ�����ڣ�'
			GOTO Error_Exit
		end
		
		DECLARE @WaterFeeSRVNo			NVARCHAR(30),
				@ElectricFeeSRVNo		NVARCHAR(30),
				@OverElectricFeeSRVNo	NVARCHAR(30)
		SET @WaterFeeSRVNo = ISNULL((SELECT TOP 1 SRVNo FROM Sys_Setting WHERE SettingCode='WaterFee'),'')
		SET @ElectricFeeSRVNo = ISNULL((SELECT TOP 1 SRVNo FROM Sys_Setting WHERE SettingCode='ElectricFee'),'')
		SET @OverElectricFeeSRVNo = ISNULL((SELECT TOP 1 SRVNo FROM Sys_Setting WHERE SettingCode='OverElectricFee'),'')
  		
  		--���ĳ����¼��״̬Ϊδ�Ʒѣ����䣩
  		UPDATE Op_Readout
  		SET IsOrder=0
  		WHERE RowPointer IN (
  			SELECT RefReadoutRP FROM Op_ContractRMRentList_Readout A
  			WHERE A.RefRentRP IN (SELECT RefNo FROM Op_OrderDetail WHERE RefRP=@OrderID) AND ISNULL(A.WPNo,'')=''
  		)
		IF @@ERROR != 0 GOTO Error_Exit
		
		
  		--���ĳ����¼��״̬Ϊδ�Ʒѣ���λ��
  		UPDATE Op_Readout SET IsOrder=0
  		WHERE RowPointer IN (
  			SELECT RefReadoutRP FROM Op_ContractRMRentList_Readout A
  			WHERE A.RefRentRP IN (SELECT RefNo FROM Op_OrderDetail WHERE RefRP=@OrderID) AND ISNULL(A.WPNo,'')<>''
  		)
  		AND (SELECT COUNT(1) FROM Op_ContractRMRentList_Readout A LEFT JOIN Op_ContractRMRentList B ON A.RefRentRP=B.RowPointer
			WHERE B.WPNo<>'' AND A.RefReadoutRP = Op_Readout.RowPointer)=1
		IF @@ERROR != 0 GOTO Error_Exit		
  --		UPDATE Op_Readout
  --		SET IsOrder=0
  --		WHERE RowPointer IN (
  --			SELECT RefReadoutRP FROM Op_ContractRMRentList_Readout A
  --			WHERE A.RefRentRP IN (SELECT RefNo FROM Op_OrderDetail WHERE RefRP=@OrderID)
  --		)
  --		AND (SELECT COUNT(1) FROM Op_ContractRMRentList_Readout WHERE RefReadoutRP=Op_Readout.RowPointer)=1
		--IF @@ERROR != 0 GOTO Error_Exit
		
		
		--ɾ�����ö�Ӧ�ĳ����¼
		DELETE FROM Op_ContractRMRentList_Readout
		WHERE RefRentRP IN (SELECT RefNo FROM Op_OrderDetail WHERE RefRP=@OrderID)
		IF @@ERROR != 0 GOTO Error_Exit	
  		
  		--���ķ����嵥
  		UPDATE Op_ContractRMRentList SET FeeStatus='0'
  		WHERE RowPointer IN (SELECT RefNo FROM Op_OrderDetail WHERE RefRP=@OrderID)
		IF @@ERROR != 0 GOTO Error_Exit
  		
  		--���ķ����嵥��ˮ��ѵĽ���Ϊ0��
  		UPDATE Op_ContractRMRentList SET FeeAmount=0
  		WHERE RowPointer IN (SELECT RefNo FROM Op_OrderDetail WHERE RefRP=@OrderID)
  			AND SRVNo IN (@WaterFeeSRVNo,@ElectricFeeSRVNo,@OverElectricFeeSRVNo)
		IF @@ERROR != 0 GOTO Error_Exit		
  		  		
  		--�ж��Ƿ�������Ķ���
		if exists(SELECT 1 FROM Op_ContractRMRentList A LEFT JOIN Op_OrderDetail B ON A.RowPointer=B.RefNo
  			WHERE B.RefRP=@OrderID AND ISNULL(A.IsRefund,0)=1)
		begin
			UPDATE Op_Contract SET ContractStatus='2',OffLeaseActulDate=null,OffLeaseStatus='2'
			WHERE RowPointer IN(
				SELECT B.RefRP FROM Op_OrderDetail A LEFT JOIN Op_ContractRMRentList B ON A.RefNo=B.RowPointer
				WHERE A.RefRP=@OrderID
			)
		end

		
  		--ɾ����ϸ
		DELETE FROM Op_OrderDetail 
		WHERE RefRP=@OrderID
		IF @@ERROR != 0 GOTO Error_Exit		
		
		--ɾ������
		DELETE FROM Op_OrderHeader 
		WHERE RowPointer=@OrderID
		IF @@ERROR != 0 GOTO Error_Exit
		

    --ROLLBACK TRAN TR_OP
	COMMIT TRAN TR_OP
	SET @InfoMsg = ''
	RETURN 1  

Error_Exit:
BEGIN	
    ROLLBACK TRAN TR_OP
    if(@InfoMsg='') SET @InfoMsg = '���ݴ����쳣��'
	RETURN -1
END



GO