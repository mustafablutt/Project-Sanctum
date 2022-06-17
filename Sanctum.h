typedef enum{typeConstant, typeID, tipIslt} nodeEnum;
typedef struct{int value;} cNodeType;
typedef struct{int i;} IDNodeType;
typedef struct{int process;int opsNum;struct nodeTypeTag *islenen[1];} isltNodeTip;
typedef struct nodeTypeTag{nodeEnum tip;union{ cNodeType constant;IDNodeType ID;isltNodeTip islt;};}nodeType;
extern int sym[26];