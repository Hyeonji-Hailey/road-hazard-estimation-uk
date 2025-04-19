# 🚧 영국 도로 위험 예측: 기상 API 및 사고 데이터(STATS19)를 활용한 R 기반 분석
*참고:*
이 프로젝트는 University of Leeds MSc Data Analaysis & Science 과정 중 Transport Data Science (2022–2023)의 일부로 진행되었습니다.
모델은 아직 개선의 여지가 있으며 추후 업데이트될 예정입니다! Python 버전도 개발 중입니다. 

## 📝 요약
이 프로젝트는 영국 내 교통 사고 데이터와 기상API를 이용하여 실시간으로 도로 위험 수준을 예측하는 것을 목표로 합니다.
과거의 교통사고 데이터와 기상 history를 결합하여 위험 예측 모델을 작성하였으며,
운전자에게 목적지까지 가장 '안전한' 경로를 제공하는 것을 목표로 합니다. 


## 📌 배경 및 동기
비, 눈, 우박, 강풍, 가시거리 저하와 같은 기상 조건은 도로 사고의 주요 원인 중 하나입니다.  
이 프로젝트는 '가장 빠른 경로'보다 '가장 안전한 경로'가 필요한 사용자를 위한 아이디어에서 출발하였습니다.


## 📊 데이터 출처
- **STATS19**: 영국 도로교통사고 데이터 (`stats19` R 패키지를 통해 수집)
- **VisualCrossing.com Weather API**: 위도/경도 기반의 과거 기상 데이터


## 🔍 분석 절차
1. STATS19 데이터의 좌표(lat/lon)를 활용하여 해당 지점의 기상 데이터 수집
2. 지리적 위치를 저수준 격자 단위로 분할
3. 사고 데이터와 기상 데이터를 병합
4. 위험도(hazard ratio) 계산 및 정규화
5. 주요 변수 선정 후 **Lasso 회귀 모델** 구축
6. 모델 성능 평가 및 시각화


## 🧠 향후 발전 방향
- 폭풍, 홍수 등 극한 기상 조건 추가
- 도로 인근 실시간 인구 밀집도 통합
- 저위험 경로 추천 기능 도입
- 전기차 vs 일반 차량 간 사고 위험 비교

## 📦 사용한 R 패키지

- `tidyverse`, `lubridate`, `stats19`, `glmnet`, `ggplot2`, `sf`

<!-- ## 📊 출력 예시

![Sample Output](output/risk_map.png) -->

## 📝 참고 사항
- 일부 데이터는 익명 처리되거나 샘플 데이터로 대체되었습니다.
- 본 프로젝트는 학술 및 포트폴리오 용도로 제작되었습니다.


## 📚 참고 문헌

- Davies, J. (2017). *Analysis of weather effects on daily road accidents*  
  https://analysisfunction.civilservice.gov.uk/wp-content/uploads/2017/01/Road-accidents.pdf

- Department for Transport, UK. (2020). *Road Investment Strategy 2: 2020–2025*  
  https://www.gov.uk/government/publications/road-investment-strategy-2-2020-to-2025

- Ito, A., et al. (2021). *Motorway Safety in Korea: Action Plan to 2030*  
  https://www.itf-oecd.org/sites/default/files/docs/motorway-safety-korea.pdf
